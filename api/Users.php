<?php

/**
 * Backend CMS
 *
 * @copyright	2011 Denis Pikusov
 * @link		http://backendcms.ru
 * @author		Denis Pikusov
 *
 */
 
require_once('Backend.php');

class Users extends Backend
{	
	// осторожно, при изменении соли испортятся текущие пароли пользователей
	private $salt = 'fhkjrr65jdia85hgfocje65javnvjh434hy2';	


	//////////////////////////////////
	// User types:
	// 1 - Guests
	// 2 - House Leaders
	// 3 - Cleaners
	//////////////////////////////////
	
	function get_users($filter = array())
	{
		$limit = 1000;
		$page = 1;
		$id_filter = '';
		$type_filter = '';
		$group_id_filter = '';
		$house_id_filter = '';
		$keyword_filter = '';

		if(isset($filter['limit']))
			$limit = max(1, intval($filter['limit']));

		if(isset($filter['page']))
			$page = max(1, intval($filter['page']));

		if(isset($filter['id']))
			$id_filter = $this->db->placehold('AND u.id in(?@)', (array)$filter['id']);

		if(isset($filter['type']))
			$type_filter = $this->db->placehold('AND u.type=?', (int)$filter['type']);

		if(isset($filter['group_id']))
			$group_id_filter = $this->db->placehold('AND u.group_id in(?@)', (array)$filter['group_id']);

		if(isset($filter['house_id']))
			$house_id_filter = $this->db->placehold('AND u.house_id in (?@)', (array)$filter['house_id']);
		
		if(isset($filter['keyword']))
		{
			$keywords = explode(' ', $filter['keyword']);
			foreach($keywords as $keyword)
				$keyword_filter .= $this->db->placehold('AND (u.name LIKE "%'.$this->db->escape(trim($keyword)).'%" OR u.email LIKE "%'.$this->db->escape(trim($keyword)).'%"  OR u.last_ip LIKE "%'.$this->db->escape(trim($keyword)).'%")');
		}
		
		$order = 'u.name';
		if(!empty($filter['sort']))
			switch ($filter['sort'])
			{
				case 'date':
				$order = 'u.created DESC';
				break;
				case 'name':
				$order = 'u.name';
				break;
			}
		

		$sql_limit = $this->db->placehold(' LIMIT ?, ? ', ($page-1)*$limit, $limit);
		// Выбираем пользователей
		$query = $this->db->placehold("SELECT 
										u.id, 
										u.type,
										u.email, 
										u.password, 
										u.name, 
										u.group_id, 
										u.house_id, 
										u.enabled, 
										u.last_ip, 
										u.created, 
										g.discount, 
										g.name as group_name 
									FROM __users u
	                                LEFT JOIN __groups g ON u.group_id=g.id 
									WHERE 1 
										$id_filter
										$type_filter
										$group_id_filter 
										$house_id_filter 
										$keyword_filter 
									ORDER BY $order $sql_limit");
		$this->db->query($query);
		return $this->db->results();
	}
		
	function count_users($filter = array())
	{
		$type_filter = '';
		$group_id_filter = '';	
		$house_id_filter = '';
		$keyword_filter = '';

		if(isset($filter['type']))
			$type_filter = $this->db->placehold('AND u.type=?', (int)$filter['type']);

		if(isset($filter['group_id']))
			$group_id_filter = $this->db->placehold('AND u.group_id in(?@)', (array)$filter['group_id']);

		if(isset($filter['house_id']))
			$house_id_filter = $this->db->placehold('AND u.house_id in (?@)', (array)$filter['house_id']);
		
		if(isset($filter['keyword']))
		{
			$keywords = explode(' ', $filter['keyword']);
			foreach($keywords as $keyword)
				$keyword_filter .= $this->db->placehold('AND u.name LIKE "%'.$this->db->escape(trim($keyword)).'%" OR u.email LIKE "%'.$this->db->escape(trim($keyword)).'%"');
		}

		// Выбираем пользователей
		$query = $this->db->placehold("SELECT count(*) as count 
							FROM __users u
                            LEFT JOIN __groups g ON u.group_id=g.id 
							WHERE 1 
								$type_filter
								$group_id_filter 
								$house_id_filter 
								$keyword_filter 
							ORDER BY u.name");
		$this->db->query($query);
		return $this->db->result('count');
	}
		
	function get_user($id)
	{
		if(gettype($id) == 'string')
			$where = $this->db->placehold(' WHERE u.email=? ', $id);
		else
			$where = $this->db->placehold(' WHERE u.id=? ', intval($id));
	
		// Выбираем пользователя
		$query = $this->db->placehold("SELECT 
										u.id, 
										u.type,
										u.email, 
										u.password, 
										u.name, 
										u.group_id, 
										u.house_id, 
										u.enabled, 
										u.last_ip, 
										u.created, 
										g.discount, 
										g.name as group_name 
									FROM __users u 
									LEFT JOIN __groups g ON u.group_id=g.id 
									$where 
									LIMIT 1", $id);
		$this->db->query($query);
		$user = $this->db->result();
		if(empty($user))
			return false;
		$user->discount *= 1; // Убираем лишние нули, чтобы было 5 вместо 5.00
		return $user;
	}
	
	public function add_user($user)
	{
		$user = (array)$user;
		if(isset($user['password']))
			$user['password'] = md5($this->salt.$user['password'].md5($user['password']));

		$count_users = $this->count_users();
			
		$query = $this->db->placehold("SELECT count(*) as count FROM __users WHERE email=?", $user['email']);
		$this->db->query($query);
		
		if($this->db->result('count') > 0 && $count_users > 0)
			return false;
		
		$query = $this->db->placehold("INSERT INTO __users SET ?%", $user);
		//echo $query; exit;
		$this->db->query($query);
		return $this->db->insert_id();
	}
		
	public function update_user($id, $user)
	{
		$user = (array)$user;
		if(isset($user['password']))
			$user['password'] = md5($this->salt.$user['password'].md5($user['password']));
		$query = $this->db->placehold("UPDATE __users SET ?% WHERE id=? LIMIT 1", $user, intval($id));
		$this->db->query($query);
		return $id;
	}
	
	/*
	*
	* Удалить пользователя
	* @param $post
	*
	*/	
	public function delete_user($id)
	{
		if(!empty($id))
		{
			$query = $this->db->placehold("UPDATE __orders SET user_id=NULL WHERE id=? LIMIT 1", intval($id));
			$this->db->query($query);
			
			$query = $this->db->placehold("DELETE FROM __users WHERE id=? LIMIT 1", intval($id));
			if($this->db->query($query))
				return true;
		}
		return false;
	}		
	
	function get_groups()
	{
		// Выбираем группы
		$query = $this->db->placehold("SELECT g.id, g.name, g.discount FROM __groups AS g ORDER BY g.discount");
		$this->db->query($query);
		return $this->db->results();
	}	
	
	function get_group($id)
	{
		// Выбираем группу
		$query = $this->db->placehold("SELECT * FROM __groups WHERE id=? LIMIT 1", $id);
		$this->db->query($query);
		$group = $this->db->result();

		return $group;
	}	
	
	
	public function add_group($group)
	{
		$query = $this->db->placehold("INSERT INTO __groups SET ?%", $group);
		$this->db->query($query);
		return $this->db->insert_id();
	}
		
	public function update_group($id, $group)
	{
		$query = $this->db->placehold("UPDATE __groups SET ?% WHERE id=? LIMIT 1", $group, intval($id));
		$this->db->query($query);
		return $id;
	}
	
	public function delete_group($id)
	{
		if(!empty($id))
		{
			$query = $this->db->placehold("UPDATE __users SET group_id=NULL WHERE group_id=? LIMIT 1", intval($id));
			$this->db->query($query);
			
			$query = $this->db->placehold("DELETE FROM __groups WHERE id=? LIMIT 1", intval($id));
			if($this->db->query($query))
				return true;
		}
		return false;
	}		
	
	public function check_password($email, $password)
	{
		$encpassword = md5($this->salt.$password.md5($password));
		$query = $this->db->placehold("SELECT id FROM __users WHERE email=? AND password=? LIMIT 1", $email, $encpassword);
		$this->db->query($query);
		if($id = $this->db->result('id'))
			return $id;
		return false;
	}
	
}