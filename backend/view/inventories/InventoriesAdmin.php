<?PHP

require_once('api/Backend.php');


class InventoriesAdmin extends Backend
{
	function fetch()
	{

		$house_id = $this->request->get('house_id', 'integer');
		$type = $this->request->get('type', 'integer');

		$house = $this->pages->get_page((int)$house_id);
		if(empty($house))
			return false;


		// Set default values
		$inventory = new stdClass;
		if($this->request->method('post'))
		{
			$inventory->id = $this->request->post('id', 'integer');
			$inventory->house_id = $house_id;
			$inventory->type = $type;
			$inventory->is_default = 1;


			if(empty($inventory->id))
			{
				$inventory->id = $this->inventories->add_inventory($inventory);
				$this->design->assign('message_success', 'updated');
			}
			else
    		{
    			$this->inventories->update_inventory($inventory->id, $inventory);
				$this->design->assign('message_success', 'updated');
    		}

    		if(!empty($inventory->id))
    		{
    			$inventory_values = $this->request->post('inv');
    			if(!empty($inventory_values))
    			{
    				foreach($inventory_values as $group_id=>$vv)
    				{
    					foreach($vv as $item_id=>$vals)
    					{
    						foreach($vals as $value_id=>$val)
    						{
    							if(empty($val))
    							{
    								if(!empty($value_id))
    									$this->inventories->delete_value($value_id);
    							}
    							else{
    								if(empty($value_id))
		    						{
		    							$value = new stdClass;
			    						$value->inventory_id = $inventory->id;
			    						$value->item_id = $item_id;
			    						$value->group_id = $group_id;
			    						$value->value = $val;
			    						$this->inventories->add_value($value);
		    						}
		    						else
		    							$this->inventories->update_value($value_id, array('value'=>$val));
    							}
	    						
	    						
	    					}
    					}
    				}
    			}
    		}

		}

		// Groups
		$groups_tree = array();
		$groups = $this->inventories->get_groups(array('type'=>$type, 'not_tree'=>1));
		if(!empty($groups))
		{
			$groups_ids = array_keys($groups);

			// Items
			$it_filter = array();
			$it_filter['house_id'] = $house_id;
			$it_filter['group_id'] = $groups_ids;
			$it_filter['type'] = $type;

			$items = array();
			$items_ = $this->inventories->get_items($it_filter);
			if(!empty($items_))
			{
				foreach($groups as $k=>$g)
				{
					$groups[$k]->items = array();
				}

				foreach($items_ as $item)
					$items[$item->id] = $item;
				unset($items_);
			}

			// Chains
			$g_chains = $this->inventories->get_items_chains(array('parent_id'=>$groups_ids, 'type'=>'group'));

			if(!empty($g_chains))
			{
				// Set items to groups
				foreach($g_chains as $c)
				{
					if(isset($groups[$c->parent_id]) && isset($items[$c->item_id]))
						$groups[$c->parent_id]->items[$c->item_id] = $items[$c->item_id];
				}
			}

			$first_column = array();
			if($type == 2) // Kitchen restocking
			{
				foreach($groups as $k=>$g)
				{
					$translit_name = $this->request->translit(trim($g->name));
					$groups[$k]->sign = $translit_name;
					if($g->parent_id != 0)
					{
						$first_column[$translit_name] = $g;
					}
				}
				foreach($groups as $k=>$g)
				{
					if($g->parent_id != 0)
					{
						$translit_name = $this->request->translit(trim($g->name));
						if(!empty($g->items))
						{
							foreach($g->items as $i)
							{
								$translit_item_name = $this->request->translit(trim($i->name));
								$first_column[$translit_name]->t_items[$translit_item_name] = $i;
							}
						}
					}
				}
			}
			



			$groups_tree = $this->categories_tree->get_categories_tree('i_groups', $groups);

			if($type == 1) // Restocking
			{
				$first_group = array_shift($groups_tree);
				$first_column_items = array();
				if(!empty($first_group->subcategories))
				{
					foreach($first_group->subcategories as $k=>$g)
					{
						if(empty($g->items))
							unset($first_group->subcategories[$k]);
						else
						{
							foreach($g->items as $i)
								$first_column_items[$i->id] = $i;
						}
					}
				}

				$this->design->assign('first_group', $first_group);
				$this->design->assign('first_column_items', $first_column_items);
			}

			$this->design->assign('first_column', $first_column);


			// Default inventory
			$i_filter = array();
			$i_filter['house_id'] = $house_id;
			$i_filter['type'] = $type;
			$i_filter['is_default'] = 1;
			$i_filter['limit'] = 1;
			$default_inventory = $this->inventories->get_inventories($i_filter);
			if(!empty($default_inventory))
			{
				$di_values_ = $this->inventories->get_values(array('inventory_id'=>$default_inventory->id));
				if(!empty($di_values_))
				{
					$di_values = array();
					foreach($di_values_ as $v)
					{
						$val = new stdClass;
						$val->id = $v->id;
						$val->value = $v->value;
						$di_values[$v->group_id][$v->item_id] = $val;
					}
					$default_inventory->values = $di_values;
					unset($di_values_);
				}
			}

			// Inventories
			$i_filter = array();
			$i_filter['house_id'] = $house_id;
			$i_filter['type'] = $type;
			$i_filter['is_default'] = 0;

			$i_filter['page'] = max(1, $this->request->get('page', 'integer')); 	
			$i_filter['limit'] = 1;
			$i_filter['return_results'] = true;

			// if($type == 2) // Kitchen restocking
			// {
			// 	$i_filter['limit'] = 1;
			// 	$i_filter['return_results'] = true;
			// }

			$inventories_count = $this->inventories->count_inventories($i_filter);


			$inventories = array();
			$inventories_ = $this->inventories->get_inventories($i_filter);

			$new_inventories = array();

			$isset_notes = 0;
			$isset_images = 0;

			if(!empty($inventories_))
			{
				$inv_users_ids = array();
				foreach($inventories_ as $inventory)
				{
					$inventories[$inventory->id] = $inventory;
					if(!empty($inventory->images))
						$inventory->images = unserialize($inventory->images);
					if(!empty($inventory->user_id))
						$inv_users_ids[$inventory->user_id][$inventory->id] = $inventory->id;

					if(!empty($inventory->note))
						$isset_notes = 1;
					if(!empty($inventory->images))
						$isset_images = 1;

					if($inventory->view == 0)
						$new_inventories[$inventory->id] = $inventory->id;
				}

				unset($inventories_);
				$inventories_ids = array_keys($inventories);
				
				// Values
				$values = $this->inventories->get_values(array('inventory_id'=>$inventories_ids));
				if(!empty($values))
				{
					foreach($values as $v)
					{
						$val = new stdClass;
						$val->id = $v->id;
						$val->value = $v->value;
						//$val->sign = $this->request->translit(trim($i->name));
						$inventories[$v->inventory_id]->values[$v->group_id][$v->item_id] = $val;
					}
					unset($values);
				}

				// Users
				if(!empty($inv_users_ids))
				{
					$users = $this->users->get_users(array('id'=>array_keys($inv_users_ids), 'limit'=>count($inv_users_ids)));
					if(!empty($users))
					{
						foreach($users as $u)
						{
							if(isset($inv_users_ids[$u->id]))
							{
								foreach($inv_users_ids[$u->id] as $inventory_id)
									$inventories[$inventory_id]->user = $u;
							}
						}
					}
				}

				if(!empty($isset_notes))
					$this->design->assign('isset_notes', 1);
				if(!empty($isset_images))
					$this->design->assign('isset_images', 1);
				
			}



		}
		

		// Houses
		//$houses = $this->pages->get_pages(array('menu_id'=>5));

		// print_r($groups_tree); exit;

		$this->design->assign('house', $house);
		$this->design->assign('type',  $type);

		$this->design->assign('groups', $groups);
		$this->design->assign('groups_tree', $groups_tree);

		$this->design->assign('default_inventory', $default_inventory);

		$this->design->assign('inventories', $inventories);

		$this->design->assign('pages_count', ceil($inventories_count/$i_filter['limit']));
		$this->design->assign('current_page', $i_filter['page']);

		if(!empty($new_inventories))
		{
			$query = $this->db->placehold("UPDATE __inventories SET view=1 WHERE id in(?@) LIMIT ?", (array)$new_inventories, count((array)$new_inventories));
			$this->db->query($query);
		}

		$tmp = 'inventories/inventories1.tpl';

		if($type == 2) // Kitchen restocking
			$tmp = 'inventories/inventories2.tpl';

		return $this->body = $this->design->fetch($tmp);
	}
}
