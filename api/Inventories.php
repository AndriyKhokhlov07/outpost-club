<?php

 
require_once('Backend.php');

class Inventories extends Backend
{
	public $all_groups;


	// ---- ITEMS ----
	///////////////////////////////////////////
	// type: 
	// 1 - Restocking 
	// 2 - Kitchen restocking
	///////////////////////////////////////////
	public function get_items($filter = array())
	{
		$id_filter = '';
		$type_filter = '';
		$group_id_filter = '';
		$house_id_filter = '';	
		$visible_filter = '';
		$group_by = '';

		if(!empty($filter['id']))
			$id_filter = $this->db->placehold('AND i.id in(?@)', (array)$filter['id']);

		if(!empty($filter['type']))
			$type_filter = $this->db->placehold('AND i.type in(?@)', (array)$filter['type']);

		if(isset($filter['group_id']))
		{
			$group_id_filter = $this->db->placehold("INNER JOIN __inventories_items_chains ic ON ic.item_id = i.id AND ic.type='group' AND ic.parent_id in(?@)", (array)$filter['group_id']);
			//$group_by = "GROUP BY i.id";
		}

		if(isset($filter['house_id']))
		{
			$house_id_filter = $this->db->placehold("INNER JOIN __inventories_items_chains ich ON ich.item_id = i.id AND ich.type='house' AND ich.parent_id in(?@)", (array)$filter['house_id']);
			//$group_by = "GROUP BY i.id";
		}

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND i.visible = ?', intval($filter['visible']));


		if(isset($filter['group_by']))
			$group_by =  "GROUP BY ".$filter['group_by'];

		$query = $this->db->placehold("SELECT 
							i.id, 
							i.type,
							i.name, 
							i.unit,
							i.description,
							i.visible,
							i.position 
						FROM __inventories_items AS i
							$group_id_filter
							$house_id_filter
						WHERE 1
							$id_filter 
							$type_filter
							$visible_filter
						$group_by
						ORDER BY i.position");


		$this->db->query($query);
		return $this->db->results();
	}


	public function get_item($id)
	{
		$query = $this->db->placehold("SELECT
							i.id, 
							i.type,
							i.name, 
							i.unit,
							i.description,
							i.visible,
							i.position 
						FROM __inventories_items AS i
						WHERE i.id=? LIMIT 1", $id);
		$this->db->query($query);
		return $this->db->result();
	}

	public function add_item($item)
	{
		$query = $this->db->placehold("INSERT INTO __inventories_items SET ?%", $item);
		$this->db->query($query);
		$id = $this->db->insert_id();
		$query = $this->db->placehold("UPDATE __inventories_items SET position=id WHERE id=? LIMIT 1", $id);
		$this->db->query($query);
		return $id;
	}
		
	public function update_item($id, $item)
	{
		$query = $this->db->placehold("UPDATE __inventories_items SET ?% WHERE id in(?@) LIMIT ?", (array)$item, (array)$id, count((array)$id));
		$this->db->query($query);
		return $id;
	}
	
	public function delete_item($id = array())
	{
		if(!empty($id))
		{
			$query = $this->db->placehold("DELETE FROM __inventories_items WHERE id=? LIMIT 1", intval($id));
			$this->db->query($query);
			$this->delete_items_chains(array('item_id'=>intval($id)));
		}
	}




	// ----  GROUPS  ----
	///////////////////////////////////////////
	// type: 
	// 1 - Restocking 
	// 2 - Kitchen restocking
	///////////////////////////////////////////
	public function get_groups($filter = array())
	{
		$groups = array();

		$id_filter = '';
		$type_filter = '';
		$visible_filter = '';
		$group_by  = '';

		if(!empty($filter['id']))
			$id_filter = $this->db->placehold('AND g.id in(?@)', (array)$filter['id']);

		if(!empty($filter['type']))
			$type_filter = $this->db->placehold('AND g.type in(?@)', (array)$filter['type']);

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND g.visible = ?', intval($filter['visible']));

		$query = $this->db->placehold("SELECT 
							g.id,
							g.parent_id,
							g.name,
							g.description,
							g.type,
							g.visible,
							g.position
						FROM __inventories_groups AS g
						WHERE 1
							$id_filter 
							$type_filter
							$visible_filter
						$group_by
						ORDER BY g.position");

		$this->db->query($query);

		$groups_ = $this->db->results();

		if(!empty($groups_))
		{
			foreach($groups_ as $group)
				$groups[$group->id] = $group;
		
			if(empty($filter['id']) && empty($filter['type']) && empty($filter['not_tree']))	
				$this->categories_tree->get_categories_tree('inventories_groups', $groups);
		}	
		return $groups;
	}

	public function get_groups_tree()
	{
		if(!isset($this->categories_tree->categories_tree['inventories_groups']))
			$this->get_groups();

		return $this->categories_tree->categories_tree['inventories_groups'];
	}

	public function get_group_init($id)
	{
		$query = $this->db->placehold("SELECT
							g.id,
							g.parent_id,
							g.name,
							g.description,
							g.type,
							g.visible,
							g.position
						FROM __inventories_groups AS g
						WHERE g.id=? LIMIT 1", $id);
		$this->db->query($query);
		return $this->db->result();
	}

	public function get_group($id)
	{
		if(!isset($this->all_groups))
			$this->get_groups_tree();
		if(is_int($id) && array_key_exists(intval($id), (array)$this->all_groups))
			return $group = $this->all_groups[intval($id)];
		
		return false;
	}

	public function add_group($group)
	{
		$query = $this->db->placehold("INSERT INTO __inventories_groups SET ?%", $group);
		$this->db->query($query);
		$id = $this->db->insert_id();
		$query = $this->db->placehold("UPDATE __inventories_groups SET position=id WHERE id=? LIMIT 1", $id);
		$this->db->query($query);
		return $id;
	}
		
	public function update_group($id, $group)
	{
		$query = $this->db->placehold("UPDATE __inventories_groups SET ?% WHERE id in(?@) LIMIT ?", (array)$group, (array)$id, count((array)$id));
		$this->db->query($query);
		return $id;
	}
	
	public function delete_group($ids)
	{
		if(empty($ids))
			return false;

		$ids = (array)$ids;
		$query = $this->db->placehold("DELETE FROM __inventories_groups WHERE id in(?@)", $ids);
		$this->db->query($query);

		foreach($ids as $id)
			$this->delete_items_chains(array('parent_id'=>$id, 'type'=>'group'));


		/*
		foreach($ids as $id)
		{
			$group = $this->get_group(intval($id));
			if(!empty($group->children))
			{
				$query = $this->db->placehold("DELETE FROM __inventories_groups WHERE id in(?@)", (array)$group->children);
				$this->db->query($query);

				foreach($group->children as $g_id)
					$this->delete_items_chains(array('parent_id'=>$g_id, 'type'=>'group'));
			}
		}
		*/
		if(isset($this->categories_tree->categories_tree['inventories_groups']))	
			unset($this->categories_tree->categories_tree['inventories_groups']);	
		unset($this->all_groups);	
		return $id;
	}



	// CHAINS
	///////////////////////////////////////////
	// Chains type: group, house
	///////////////////////////////////////////
	public function get_items_chains($filter = array())
	{
		$item_id_filter = '';
		$parent_id_filter = '';
		$type_filter = ''; 

		if(!empty($filter['item_id']))
			$item_id_filter = $this->db->placehold('AND ic.item_id in(?@)', (array)$filter['item_id']);

		if(!empty($filter['parent_id']))
			$parent_id_filter = $this->db->placehold('AND ic.parent_id in(?@)', (array)$filter['parent_id']);

		if(!empty($filter['type']))
			$type_filter = $this->db->placehold('AND ic.type in(?@)', (array)$filter['type']);


		$query = $this->db->placehold("SELECT 
							ic.item_id, 
							ic.parent_id, 
							ic.type
						FROM __inventories_items_chains AS ic
						WHERE 1
							$item_id_filter 
							$parent_id_filter
							$type_filter");

		$this->db->query($query);
		return $this->db->results();
	}

	public function add_items_chains($value)
	{
		$query = $this->db->placehold("INSERT IGNORE INTO __inventories_items_chains SET ?%", $value);
		$this->db->query($query);
	}

	public function delete_items_chains($filter = array())
	{
		$item_id_filter = '';
		$parent_id_filter = '';
		$type_filter = '';
		$limit = '';

		if(!empty($filter['item_id']))
			$item_id_filter = $this->db->placehold('AND item_id in(?@)', (array)$filter['item_id']);

		if(!empty($filter['parent_id']))
			$parent_id_filter = $this->db->placehold('AND parent_id in(?@)', (array)$filter['parent_id']);

		if(!empty($filter['type']))
			$type_filter = $this->db->placehold('AND type in(?@)', (array)$filter['type']);

		if(!empty($filter['limit']))
			$limit = $this->db->placehold('LIMIT ?', intval($filter['limit']));

		$query = $this->db->placehold("DELETE 
						FROM __inventories_items_chains
						WHERE 1
							$item_id_filter 
							$parent_id_filter
							$type_filter
						$limit");

		$this->db->query($query);
	}

	public function update_items_chains($filter = array(), $value)
	{

		if(!empty($filter))
		{
			// $filter['limit'] = 1;
			$this->delete_items_chains($filter);
		}

		if(!empty($value))
		{
			if(is_array($value))
			{
				foreach($value as $v)
					$this->add_items_chains($v);
			}
			else
				$this->add_items_chains($value);
		}
	}



	// ---- INVENTORIES ----
	///////////////////////////////////////////
	// type: 
	// 1 - Restocking 
	// 2 - Kitchen restocking
	///////////////////////////////////////////

	public function get_inventories($filter = array())
	{
		$id_filter = '';
		$type_filter = '';
		$user_id_filter = '';
		$house_id_filter = '';	
		$is_default_filter = '';
		$view_filter = '';
		$date_filter = '';

		$limit = '';
		$sql_limit = '';
		$page = 1;

		// if(isset($filter['limit']))
		// 	$limit = $this->db->placehold('LIMIT ?', (int)$filter['limit']);

		if(isset($filter['limit']))
			$limit = max(1, intval($filter['limit']));

		if(isset($filter['page']))
			$page = max(1, intval($filter['page']));


		if(!empty($filter['id']))
			$id_filter = $this->db->placehold('AND i.id in(?@)', (array)$filter['id']);

		if(!empty($filter['type']))
			$type_filter = $this->db->placehold('AND i.type=?', (int)$filter['type']);

		if(!empty($filter['user_id']))
			$user_id_filter = $this->db->placehold('AND i.user_id=?', (int)$filter['user_id']);

		if(!empty($filter['house_id']))
			$house_id_filter = $this->db->placehold('AND i.house_id=?', (int)$filter['house_id']);

		if(isset($filter['is_default']))
			$is_default_filter = $this->db->placehold('AND i.is_default=?', intval($filter['is_default']));

		if(isset($filter['view']))
			$view_filter = $this->db->placehold('AND i.view=?', intval($filter['view']));


		if(isset($filter['date']))
		{
			if($filter['date'] == 'today')
				$date_filter = 'AND i.date>=CURDATE()';
		}

		if(!empty($limit))
			$sql_limit = $this->db->placehold(' LIMIT ?, ? ', ($page-1)*$limit, $limit);

		$query = $this->db->placehold("SELECT 
							i.id, 
							i.type,
							i.user_id,
							i.house_id,
							i.date,
							i.note,
							i.images,
							i.is_default,
							i.view
						FROM __inventories AS i
						WHERE 1
							$id_filter 
							$type_filter
							$user_id_filter
							$house_id_filter
							$is_default_filter
							$view_filter
							$date_filter
						ORDER BY i.id DESC
						$sql_limit");

		$this->db->query($query);

		if(isset($filter['limit']) && $filter['limit'] == 1 && empty($filter['return_results']))
			return $this->db->result();
		else
			return $this->db->results();
	}


	public function count_inventories($filter = array())
	{
		$id_filter = '';
		$type_filter = '';
		$user_id_filter = '';
		$house_id_filter = '';	
		$is_default_filter = '';
		$view_filter = '';

		if(!empty($filter['id']))
			$id_filter = $this->db->placehold('AND i.id in(?@)', (array)$filter['id']);

		if(!empty($filter['type']))
			$type_filter = $this->db->placehold('AND i.type=?', (int)$filter['type']);

		if(!empty($filter['user_id']))
			$user_id_filter = $this->db->placehold('AND i.user_id=?', (int)$filter['user_id']);

		if(!empty($filter['house_id']))
			$house_id_filter = $this->db->placehold('AND i.house_id=?', (int)$filter['house_id']);

		if(isset($filter['is_default']))
			$is_default_filter = $this->db->placehold('AND i.is_default=?', intval($filter['is_default']));

		if(isset($filter['view']))
			$view_filter = $this->db->placehold('AND i.view=?', intval($filter['view']));



		$query = $this->db->placehold("SELECT 
							COUNT(distinct i.id) as count
						FROM __inventories AS i
						WHERE 1
							$id_filter 
							$type_filter
							$user_id_filter
							$house_id_filter
							$is_default_filter
							$view_filter
						");

		if($this->db->query($query))
			return $this->db->result('count');
		else
			return false;
	}


	public function add_inventory($value)
	{
		$value = (object)$value;
		$set_curr_date = '';
		if(empty($value->date))
			$set_curr_date = ', date=now()';

		$query = $this->db->placehold("INSERT INTO __inventories SET ?%$set_curr_date", $value);
		$this->db->query($query);
		return $this->db->insert_id();
	}

	public function update_inventory($id, $value)
	{
		$value = (object)$value;
		$set_curr_date = '';
		if(empty($value->date))
			$set_curr_date = ', date=now()';

		$query = $this->db->placehold("UPDATE __inventories SET ?%$set_curr_date WHERE id in(?@) LIMIT ?", (array)$value, (array)$id, count((array)$id));
		$this->db->query($query);
		return $id;
	}

	public function delete_inventory($id)
	{
		if(!empty($id))
		{
			$query = $this->db->placehold("DELETE FROM __inventories WHERE id=? LIMIT 1", intval($id));
			$this->db->query($query);
		}
	}



	// ---- VALUES ----
	///////////////////////////////////////////

	public function get_values($filter = array())
	{
		$id_filter = '';
		$inventory_id_filter = '';
		$limit = '';

		if(isset($filter['limit']))
			$limit = $this->db->placehold('LIMIT ?', (int)$filter['limit']);

		if(!empty($filter['id']))
			$id_filter = $this->db->placehold('AND v.id in(?@)', (array)$filter['id']);

		if(!empty($filter['inventory_id']))
			$inventory_id_filter = $this->db->placehold('AND v.inventory_id in(?@)', (array)$filter['inventory_id']);

		$query = $this->db->placehold("SELECT 
							v.id, 
							v.inventory_id,
							v.item_id,
							v.group_id,
							v.value
						FROM __inventories_values AS v
						WHERE 1
							$id_filter
							$inventory_id_filter
						ORDER BY v.id
						$limit");

		$this->db->query($query);
		return $this->db->results();
	}

	public function add_value($value)
	{
		$query = $this->db->placehold("INSERT INTO __inventories_values SET ?%", $value);
		$this->db->query($query);
		return $this->db->insert_id();
	}

	public function update_value($id, $value)
	{
		$query = $this->db->placehold("UPDATE __inventories_values SET ?% WHERE id in(?@) LIMIT ?", (array)$value, (array)$id, count((array)$id));
		$this->db->query($query);
		return $id;
	}

	public function delete_value($id)
	{
		if(!empty($id))
		{
			$query = $this->db->placehold("DELETE FROM __inventories_values WHERE id=? LIMIT 1", intval($id));
			$this->db->query($query);
		}
	}



	












}
