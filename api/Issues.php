<?php

require_once('Backend.php');

class Issues extends Backend
{
	
	public function get_issues($filter = array())
	{
		$id_filter = '';	
		$house_id_filter = '';
		$visible_filter = '';

		if(!empty($filter['id']))
			$id_filter = $this->db->placehold('AND id in(?@)', (array)$filter['id']);

		if(isset($filter['house_id']))
			$house_id_filter = $this->db->placehold('AND house_id in (?@)', (array)$filter['house_id']);

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND visible = ?', intval($filter['visible']));

		$query = "SELECT 
					id,
					house_id,
					email_guest,
					assignment,
					status,
					date_start,
					date_completion,
					assigned,
					details,
					visible
		          FROM __issues 
				  WHERE 1 
				  	$id_filter
				  	$house_id_filter 
					$visible_filter 
				  ORDER BY date_start DESC";
	
		$this->db->query($query);
		return $this->db->results();
	}


	public function get_issue($id)
	{
		$query = $this->db->placehold("SELECT 
					id,
					house_id,
					email_guest,
					assignment,
					status,
					date_start,
					date_completion,
					assigned,
					details,
					visible
		          FROM __issues 
				  WHERE id=? 
				  LIMIT 1", intval($id));

		$this->db->query($query);
		return $this->db->result();
	}

	
	public function add_issue($issue)
	{	
		$query = $this->db->placehold('INSERT INTO __issues SET ?%', $issue);
		if(!$this->db->query($query))
			return false;

		return $this->db->insert_id();
	}
	

	public function update_issue($id, $issue)
	{	
		$query = $this->db->placehold('UPDATE __issues SET ?% WHERE id in (?@)', $issue, (array)$id);
		if(!$this->db->query($query))
			return false;
		return $id;
	}
	

	public function delete_issue($id)
	{
		if(!empty($id))
		{			
			$query = $this->db->placehold("DELETE FROM __issues WHERE id=? LIMIT 1", intval($id));
			if($this->db->query($query))
				return true;
		}
		return false;
	}	
		
}
