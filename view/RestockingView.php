<?php

require_once('View.php');

class RestockingView extends View
{
	private $restocking_type;
	private $title;

	public function fetch()
	{
		// Restocking types:
		// 1 - Restocking
		// 2 - Kitchen restocking

		// Users types:
		// 1 - Guests
		// 2 - House Leades
		// 3 - Cleaners

		
		$house_id = $this->request->get('house_id', 'integer');

		if(empty($this->user))
		{
			header('Location: '.$this->config->root_url.'/user/login');
			exit();
		}
		if($this->user->type == 1)
		{
			header('Location: '.$this->config->root_url.'/current-members');
			exit();
		}


		if($this->user->type == 2)
			$this->restocking_type = 2;
		elseif($this->user->type == 3)
			$this->restocking_type = 1;


		if($this->restocking_type == 1)
			$this->title = 'Restocking';
		elseif($this->restocking_type == 2)
			$this->title = 'Kitchen restocking';
		
		$this->design->assign('meta_title', $this->title);
		$this->design->assign('title', $this->title);


		if(!empty($house_id))
		{
			return $this->fetch_restocking($house_id);
		}
		else
		{
			return $this->fetch_select_house();
		}
	}


	// Select House
	private function fetch_select_house($url)
	{
		// Houses
		//$houses = array();
		$houses = $this->pages->get_pages(array('menu_id'=>5, 'visible'=>1, 'not_tree'=>1));
		if(!empty($houses))
		{
			foreach($houses as $k=>$h)
			{
				if(!empty($h->annotation))
				{
					preg_match('~>(.*)<~', $h->annotation, $anot_arr);
					if(!empty($anot_arr[1]))
						$houses[$k]->location = $anot_arr[1];
				}
			}
			$houses= $this->categories_tree->get_categories_tree('houses', $houses);
		}
			

		$this->design->assign('houses', $houses);

		return $this->design->fetch('restocking/restocking_houses.tpl');
	}


	private function fetch_restocking($house_id)
	{
		$send_email = false;

		if(empty($house_id))
			return false;

		$house_ = $this->pages->get_page((int)$house_id);

		if(empty($house_) || (!$house_->visible && empty($_SESSION['admin'])))
			return false;

		// House
		$house = new stdClass;
		$house->id = $house_id;
		$house->name = $house_->name;
		unset($house_);



		$inventory = new stdClass;
		if($this->request->method('post'))
		{
			$inventory->id 		 = $this->request->post('id', 'integer');
			$inventory->house_id = $house->id;
			$inventory->user_id  = $this->user->id;
			$inventory->type 	 = $this->restocking_type;
			$inventory->view 	 = 0;
			$inventory->note 	 = $this->request->post('note');


			$old_images = array();
			if(empty($inventory->id))
			{
				$inventory->id = $this->inventories->add_inventory($inventory);
				$this->design->assign('message_success', 'added');
			}
			else
    		{
    			$inventory_images = $this->request->post('images');
    			$old_inventory = $this->inventories->get_inventories(array('id'=>$inventory->id, 'limit'=>1));
    			if(!empty($old_inventory))
    			{
    				if(!empty($old_inventory->images))
    					$old_images = unserialize($old_inventory->images);
    				unset($old_inventory);
    			}

    			if(!empty($inventory_images))
    			{
    				foreach($inventory_images as $i)
    				{
    					$k = array_search($i, $old_images);
    					if($k !== false)
    					{
    						unset($old_images[$k]);
    					}

    				}
    				$inventory->images = serialize($inventory_images);
    			}
    			else
    				$inventory->images = '';

    			if(!empty($old_images))
    			{
    				// Delete images
    				foreach($old_images as $i)						
						@unlink($this->config->root_dir.$this->config->inventories_images_dir.$i);	
    			}

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


    			// Загрузка drag-n-drop файлов
    			$i_images = array();
	  		    if($images = $this->request->post('images_urls'))
	  		    {
					foreach($images as $url)
					{
				 		if($dropped_images = $this->request->files('dropped_images'))
				  		{
				 			$key = array_search($url, $dropped_images['name']);
						 	if ($key!==false && $image_name = $this->image->upload_image($dropped_images['tmp_name'][$key], $dropped_images['name'][$key], 'inventories'))
						 	{
						 		// Resize image
						 		$imagesize = getimagesize($this->config->root_dir.$this->config->inventories_images_dir.$image_name);
						 		if($imagesize[0] > 1000)
						 		{
						 			$this->simpleimage->load($this->config->root_dir.$this->config->inventories_images_dir.$image_name);
									$this->simpleimage->resizeToWidth(1000);
									$this->simpleimage->save($this->config->root_dir.$this->config->inventories_images_dir.$image_name);
						 		}
						 		$i_images[] = $image_name;
						 	}
					  	   	
						}
					}
				}

				if(!empty($i_images))
				{
					$images_arr =  array();
					$old_inventory = $this->inventories->get_inventories(array('id'=>$inventory->id, 'limit'=>1));

					if(!empty($old_inventory))
	    			{
	    				if(!empty($old_inventory->images))
	    				{
	    					$old_images = unserialize($old_inventory->images);
	    					if(!empty($old_images))
	    					{
		    					foreach($old_images as $i)
		    						$images_arr[] = $i;
	    					}

	    				}
	    				unset($old_inventory);
	    			}
	    			foreach($i_images as $i)
	    				$images_arr[] = $i;

					$this->inventories->update_inventory($inventory->id, array('images'=>serialize($images_arr)));
				}


				$send_email = true;

    		}

		}


		// Groups
		// $groups_tree = array();
		$groups = $this->inventories->get_groups(array('type'=>$this->restocking_type, 'visible'=>1, 'not_tree'=>1));
		if(!empty($groups))
		{
			$groups_ids = array_keys($groups);

			// Items
			$it_filter = array();
			$it_filter['house_id'] = $house_id;
			$it_filter['group_id'] = $groups_ids;
			$it_filter['type'] 	   = $this->restocking_type;
			$it_filter['visible']  = 1;

			$items = array();
			$items_ = $this->inventories->get_items($it_filter);
			if(!empty($items_))
			{
				foreach($groups as $k=>$g)
					$groups[$k]->items = array();

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

			$groups_tree = $this->categories_tree->get_categories_tree('i_groups', $groups);


			// Inventory
			$i_filter = array();
			$i_filter['house_id'] = $house->id;
			$i_filter['user_id'] = $this->user->id;
			$i_filter['type'] = $this->restocking_type;
			$i_filter['date'] = 'today';
			$i_filter['limit'] = 1;
			$inventory = $this->inventories->get_inventories($i_filter);
			if(!empty($inventory))
			{

				$di_values_ = $this->inventories->get_values(array('inventory_id'=>$inventory->id));
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
					$inventory->values = $di_values;
					unset($di_values_);
				}

				if(!empty($inventory->images))
					$inventory->images = unserialize($inventory->images);
			}

		}

		//print_r($groups_tree); exit;

		$this->design->assign('house', $house);
		$this->design->assign('groups', $groups);
		$this->design->assign('groups_tree', $groups_tree);
		if(!empty($inventory))
		{
			$this->design->assign('inventory', $inventory);

			// Send Email
			if($send_email == true)
			{
				$mail_to = $this->settings->order_email;
				if($this->restocking_type == 1) // Restocking
					$mail_to = $this->settings->restocking_email;
				elseif($this->restocking_type == 2) // Kitchen restocking
					$mail_to = $this->settings->krestocking_email;

				$email_template = $this->design->fetch($this->config->root_dir.'backend/design/html/inventories/email_inventory.tpl');
				$subject = $this->title.': '.$house->name.' ('.$this->user->name.' - '.$this->user->email.')';
				$this->notify->email($mail_to, $subject, $email_template, $this->settings->notify_from_email);
			}
		}
		
		return $this->design->fetch('restocking/restocking.tpl');
	}

}
