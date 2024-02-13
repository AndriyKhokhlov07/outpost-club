<?PHP

require_once('api/Backend.php');


class InventoriesItemsAdmin extends Backend
{
	function fetch()
	{
		if($this->request->method('post'))
		{  	
			// Действия с выбранными
			$ids = $this->request->post('check');
			if(is_array($ids))
			switch($this->request->post('action'))
			{
				case 'disable':
			    {
			    	foreach($ids as $id)
						$this->inventories->update_item($id, array('visible'=>0));    
					break;
			    }
			    case 'enable':
			    {
			    	foreach($ids as $id)
						$this->inventories->update_item($id, array('visible'=>1));    
			        break;
			    }
			    case 'delete':
			    {
			    	foreach($ids as $id)
			    	{
			    		$this->inventories->delete_item($id); 
					}
			        break;
			    }
			}		
	  	
			// Сортировка
			$positions = $this->request->post('positions');
	 		$ids = array_keys($positions);
			sort($positions);
			foreach($positions as $i=>$position)
				$this->inventories->update_item($ids[$i], array('position'=>$position)); 

		} 

		$filter = array();
	
		// Groups
		$groups = $this->inventories->get_groups_tree();
		$group = null;
		
		$group_id = $this->request->get('group_id', 'integer');
		if(!empty($group_id))
		{
			$group = $this->inventories->get_group($group_id);
			$filter['group_id'] = $group->children;
		}

		// Houses
		$houses = $this->pages->get_pages(array('menu_id'=>5, 'not_tree'=>1));
		if(!empty($houses))
			$houses= $this->categories_tree->get_categories_tree('houses', $houses);
		$house = null;
		$house_id = $this->request->get('house_id', 'integer');
		if(!empty($house_id))
		{
			$house = $this->pages->get_page($house_id);
			$filter['house_id'] = $house->id;
		}

		$type = false;
		$type_ = $this->request->get('type', 'integer');
		if(!empty($type_))
		{
			$type = $type_;
			$filter['type'] = $type;
		}
		$filter['group_by'] = 'i.id';
		
		$items = $this->inventories->get_items($filter);
		
		$this->design->assign('groups', $groups);
		$this->design->assign('group',  $group);
		$this->design->assign('houses', $houses);
		$this->design->assign('house',  $house);
		$this->design->assign('type',   $type);

		$this->design->assign('items',  $items);
		return $this->body = $this->design->fetch('inventories/items.tpl');
	}
}
