<?PHP
require_once('api/Backend.php');

class InventoriesItemAdmin extends Backend
{

	function fetch()
	{
		$item = new stdClass;
		if($this->request->method('post'))
		{
			$item->id   = $this->request->post('id', 'integer');
			$item->name = $this->request->post('name');
			$item->unit = $this->request->post('unit');
			$item->description = $this->request->post('description');
			$item->type = $this->request->post('type', 'integer');
			$item->visible = intval($this->request->post('visible'));

			$item_groups = $this->request->post('item_groups');
			$item_houses = $this->request->post('item_houses');

			if(empty($item->id))
			{
  				$item->id = $this->inventories->add_item($item);
  				$item = $this->inventories->get_item($item->id);
				$this->design->assign('message_success', 'added');
  			}
			else
			{
				$this->inventories->update_item($item->id, $item);
				$item = $this->inventories->get_item($item->id);
				$this->design->assign('message_success', 'updated');
			}
			
			if(!empty($item))
			{
				// Groups
				if(!empty($item_groups))
				{
					$i_groups = array();
					foreach($item_groups as $group_id)
					{
						$ig = new stdClass;
						$ig->item_id = $item->id;
						$ig->parent_id = $group_id;
						$ig->type = 'group';
						$i_groups[] = $ig;
					}
					$item_groups = $i_groups;
				}
				$this->inventories->update_items_chains(array('item_id'=>$item->id, 'type'=>'group'), $item_groups);

				// Houses
				if(!empty($item_houses))
				{
					$i_houses = array();
					foreach($item_houses as $house_id)
					{
						$ih = new stdClass;
						$ih->item_id = $item->id;
						$ih->parent_id = $house_id;
						$ih->type = 'house';
						$i_houses[] = $ih;
					}
					$item_houses = $i_houses;
				}
				$this->inventories->update_items_chains(array('item_id'=>$item->id, 'type'=>'house'), $item_houses);
			}
			
		}
		else
		{
			$item->id = $this->request->get('id', 'integer');
			$item = $this->inventories->get_item($item->id);
		}

		
		$item_groups = array();	
		$item_houses = array();	
		if(!empty($item))
		{	
			// Groups
			$item_groups_ = $this->inventories->get_items_chains(array('item_id'=>$item->id, 'type'=>'group'));
			if(!empty($item_groups_))
			{
				foreach($item_groups_ as $ig)
					$item_groups[] = $ig->parent_id;
			}

			// Houses
			$item_houses_ = $this->inventories->get_items_chains(array('item_id'=>$item->id, 'type'=>'house'));
			if(!empty($item_houses_))
			{
				foreach($item_houses_ as $ih)
					$item_houses[] = $ih->parent_id;
			}
		}
		$groups = $this->inventories->get_groups_tree();
		$houses = $this->pages->get_pages(array('menu_id'=>5, 'not_tree'=>1));
		if(!empty($houses))
			$houses= $this->categories_tree->get_categories_tree('houses', $houses);

		
		$this->design->assign('item', $item);
		$this->design->assign('item_groups', $item_groups);
		$this->design->assign('item_houses', $item_houses);
		$this->design->assign('groups', $groups);
		$this->design->assign('houses', $houses);

		return $this->body = $this->design->fetch('inventories/item.tpl');
	}
}




