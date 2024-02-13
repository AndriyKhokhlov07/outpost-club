<?php

require_once('Backend.php');

class Loans extends Backend
{

	public function get_loans($filter = array())
	{
		$id_filter = '';	
		$type_filter = '';
		$visible_filter = '';
		$loans = array();
		
		if(!empty($filter['id']))
			$id_filter = $this->db->placehold('AND id in(?@)', (array)$filter['id']);

		if(isset($filter['type']))
			$type_filter = $this->db->placehold('AND type in (?@)', (array)$filter['type']);

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND visible = ?', intval($filter['visible']));
		
		$query = "SELECT 
					id, 
					type, 
					image, 
					name,
					price,
					description, 
					position, 
					visible
		          FROM __loans 
				  WHERE 1 
				  	$id_filter
				  	$type_filter 
					$visible_filter 
				  ORDER BY position";
	
		$this->db->query($query);
			
		return $this->db->results();
	}
	
	
	public function get_loan($id)
	{
		$query = $this->db->placehold('SELECT
					id, 
					type, 
					image,  
					name,
					price,
					description, 
					position, 
					visible
				FROM __loans 
				WHERE id=?
				LIMIT 1', intval($id));

		$this->db->query($query);
		return $this->db->result();
	}

	public function add_loan($loan)
	{	
		$query = $this->db->placehold('INSERT INTO __loans SET ?%', $loan);
		if(!$this->db->query($query))
			return false;

		$id = $this->db->insert_id();
		$this->db->query("UPDATE __loans SET position=id WHERE id=?", $id);	
		return $id;
	}
	
	public function update_loan($id, $loan)
	{	
		$query = $this->db->placehold('UPDATE __loans SET ?% WHERE id in (?@)', $loan, (array)$id);
		if(!$this->db->query($query))
			return false;
		return $id;
	}
		
	public function delete_loan($id)
	{
		if(!empty($id))
		{
			$this->delete_image($id);
			
			$query = $this->db->placehold("DELETE FROM __loans WHERE id=? LIMIT 1", intval($id));
			if($this->db->query($query))
				return true;
		}
		return false;
	}
	
	// Удалить изображение
	public function delete_image($loans_ids){
		$loans_ids = (array) $loans_ids;
		$query = $this->db->placehold("SELECT image FROM __loans WHERE id in(?@)", $loans_ids);
		$this->db->query($query);
		$filenames = $this->db->results('image');
		if(!empty($filenames)){
			$query = $this->db->placehold("UPDATE __loans SET image=NULL WHERE id in(?@)", $loans_ids);
			$this->db->query($query);
			foreach($filenames as $filename){
				$query = $this->db->placehold("SELECT count(*) as count FROM __loans WHERE image=?", $filename);
				$this->db->query($query);
				$count = $this->db->result('count');
				if($count == 0){
					$file = pathinfo($filename, PATHINFO_FILENAME);
					$ext = pathinfo($filename, PATHINFO_EXTENSION);
			
					// Удалить все ресайзы
					$rezised_images = glob($this->config->root_dir.$this->config->resized_loans_images_dir.$file."*.".$ext);
					if(is_array($rezised_images))
						foreach (glob($this->config->root_dir.$this->config->resized_loans_images_dir.$file."*.".$ext) as $f)
							@unlink($f);

					@unlink($this->config->root_dir.$this->config->loans_images_dir.$filename);	
				}
			}	
		}
	}
	
}
