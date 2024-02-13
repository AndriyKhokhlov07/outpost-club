<?php

require_once('api/Backend.php');

class InventoriesGroupAdmin extends Backend
{
  
  function fetch()
  {
		$group = new stdClass;
		if($this->request->method('post'))
		{
			$group->id = $this->request->post('id', 'integer');
			$group->parent_id = $this->request->post('parent_id', 'integer');
			$group->name = $this->request->post('name');
			$group->type = $this->request->post('type', 'integer');
			$group->visible = $this->request->post('visible', 'boolean');		
			$group->description = $this->request->post('description');
	

			if(empty($group->id))
			{
  				$group->id = $this->inventories->add_group($group);
				$this->design->assign('message_success', 'added');
  			}
    		else
    		{
    			$this->inventories->update_group($group->id, $group);
				$this->design->assign('message_success', 'updated');
    		}

    		$group = $this->inventories->get_group(intval($group->id));
		}
		else
		{
			$group->id = $this->request->get('id', 'integer');
			$group = $this->inventories->get_group($group->id);
		}
		
		$groups = $this->inventories->get_groups_tree();

		$this->design->assign('group', $group);
		$this->design->assign('groups', $groups);
		return  $this->design->fetch('inventories/group.tpl');
	}
}