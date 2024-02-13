<?PHP

require_once('api/Backend.php');


class InventoriesGroupsAdmin extends Backend
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
						$this->inventories->update_group($id, array('visible'=>0));    
					break;
			    }
			    case 'enable':
			    {
			    	foreach($ids as $id)
						$this->inventories->update_group($id, array('visible'=>1));    
			        break;
			    }
			    case 'delete':
			    {
					$this->inventories->delete_group($ids);    
			        break;
			    }
			}		
	  	
			// Сортировка
			$positions = $this->request->post('positions');
	 		$ids = array_keys($positions);
			sort($positions);
			foreach($positions as $i=>$position)
				$this->inventories->update_group($ids[$i], array('position'=>$position)); 

		}

		$filter = array();

		$type = '';
		$type_ = $this->request->get('type', 'integer');
		if(!empty($type_))
		{
			$type = $type_;
			$filter['type'] = $type;
		}
  		

  		$filter['not_tree'] = 1;
		$groups = $this->inventories->get_groups($filter);
		if(!empty($groups))
			$groups = $this->categories_tree->get_categories_tree('i_groups', $groups);	

		$this->design->assign('type', $type);

		$this->design->assign('groups', $groups);
		return $this->design->fetch('inventories/groups.tpl');
	}
}
