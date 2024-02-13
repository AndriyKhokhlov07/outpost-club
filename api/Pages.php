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

class Pages extends Backend
{
	
	public $all_pages;

	/*
	*
	* Функция возвращает массив страниц, удовлетворяющих фильтру
	* @param $filter
	*
	*/
	public function get_pages($filter = array())
	{
		$limit = 1000;
		$page_id_filter = '';	
		$menu_filter = '';
		$parent_id_filter = '';
		$not_parent_id_filter = '';
		$old_url_filter = '';
		$keyword_filter = '';
		$visible_filter = '';
		$new_filter = '';
		$neighborhood_filter = '';
        $neighborhood_id_filter = '';
        $neighborhood_id = false;
		$applicaation_page_id_filter = '';
		$pages = array();

		if(isset($filter['limit']))
			$limit = max(1, intval($filter['limit']));
		
		if(!empty($filter['id']))
			$page_id_filter = $this->db->placehold('AND id in(?@)', (array)$filter['id']);

		if(isset($filter['menu_id']))
			$menu_filter = $this->db->placehold('AND menu_id in (?@)', (array)$filter['menu_id']);
			
		if(isset($filter['parent_id']))
			$parent_id_filter = $this->db->placehold('AND parent_id=?', (int)$filter['parent_id']);

		if(isset($filter['not_parent_id']))
			$not_parent_id_filter = $this->db->placehold('AND parent_id!=?', (int)$filter['not_parent_id']);

		if(!empty($filter['old_url']))
			$old_url_filter = $this->db->placehold('AND old_url!=""');	

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND visible = ?', intval($filter['visible']));

		if(isset($filter['new']))
			$new_filter = $this->db->placehold('AND new = ?', intval($filter['new']));
		

		if(isset($filter['neighborhood']))
			$neighborhood_filter = $this->db->placehold('AND neighborhood = ?', intval($filter['neighborhood']));

        if(isset($filter['neighborhood_id'])) {
            $neighborhood_id_filter = $this->db->placehold('AND neighborhood_id in(?@)', (array)$filter['neighborhood_id']);
            $neighborhood_id = (array)$filter['neighborhood_id'];
        }

		if(isset($filter['applicaation_page_id']))
			$applicaation_page_id_filter = $this->db->placehold('AND applicaation_page_id = ?', intval($filter['applicaation_page_id']));


		if(!empty($filter['keyword']))
		{
			$keywords = explode(' ', $filter['keyword']);
			foreach($keywords as $k)
			{
				$kw = $this->db->escape(trim($k));
				if($kw!=='')
				{
					if(!empty($keyword_filter))
						$keyword_filter .= 'AND ';
					else
						$keyword_filter .= 'AND(';
					$keyword_filter .= $this->db->placehold("name LIKE '%$kw%' ");

				}
			}
			$keyword_filter .= ')';
		}

				
		$query = "SELECT 
					id, 
					parent_id, 
					nebo_id,
					url, 
					old_url,
					header, 
					name, 
					meta_title, 
					meta_description, 
					meta_keywords, 
					annotation, 
					bg_text,
					body,
                    body2,
					menu_id, 
					service_ids,
					image, 
					bg_image,
					icon,
					position, 
					visible,
					coming_soon,
					featured,
					new,
					rating,
					votes,
					move_in,
					blocks,
					blocks2,
					related,
					related_houses,
					neighborhood,
					neighborhood_id,
					latitude,
					longitude,
					applicaation_page_id,
					apply_name,
					date_modified
		          FROM __pages 
				  WHERE 1 
				  	$page_id_filter
				  	$menu_filter 
					$parent_id_filter
					$not_parent_id_filter 
					$old_url_filter
					$keyword_filter
					$visible_filter 
					$new_filter
					$neighborhood_filter
				    $neighborhood_id_filter
					$applicaation_page_id_filter
				  ORDER BY position
				  LIMIT $limit";
	
		$this->db->query($query);

		$pages = [];
		foreach ($this->db->results() as $page) {
            if ($page->menu_id == 5 && $page->parent_id != 0) {
                $page->annotation = $this->addNeighborhoodLink($page->annotation, $neighborhood_id);
            }
            $pages[$page->id] = $page;
        }
		
		if(empty($filter['id']) && (!isset($filter['not_parent_id']) || $filter['not_parent_id']!==0) && (empty($filter['old_url'])) && (empty($filter['not_tree'])))	
			$this->categories_tree->get_categories_tree('pages', $pages);
			
		return $pages;
	}


    private $neighborhoods;

    public function getNeighborhoods($params = [])
    {
        if (empty($this->neighborhoods)) {
            $params['menu_id'] = 16;
            $params['visible'] = 1;
            $params['not_tree'] = true;
            $this->neighborhoods = $this->get_pages($params);
        }
        return $this->neighborhoods;
    }
    private function addNeighborhoodLink($text, $neighborhood_id) {
        $result = '';
        if (!empty($text)) {
            $neighborhoods = $this->getNeighborhoods();
            if (!empty($neighborhoods)) {
                foreach ($neighborhoods as $n) {
                    if (!$neighborhood_id || !in_array($n->id, $neighborhood_id)) {
                        $text = str_replace($n->name, '<a href="'.$n->url.'">'.$n->name.'</a>', $text);
                    }
                }
            }
            $result = $text;
        }
        return $result;
    }

	public function get_pages_tree()
	{
		if(!isset($this->categories_tree->categories_tree['pages']))
			$this->get_pages();
			
		//$this->categories_tree->categories_tree['pages']
		return $this->categories_tree->categories_tree['pages'];
	}
	
	

	/*
	*
	* Функция возвращает страницу по ее id или url (в зависимости от типа)
	* @param $id id или url страницы
	*
	*/
	public function get_page($id)
	{
		if(gettype($id) == 'string')
			$where = $this->db->placehold(' WHERE url=? ', $id);
		else
			$where = $this->db->placehold(' WHERE id=? ', intval($id));
		
		$query = "SELECT id, parent_id, nebo_id, url, old_url, header, name, meta_title, meta_description, meta_keywords, annotation, bg_text, body, body2, menu_id, service_ids, image, bg_image, icon, position, visible, new, coming_soon, featured, rating, votes, move_in, blocks, blocks2, related, related_houses, neighborhood, neighborhood_id, latitude, longitude, applicaation_page_id,
		apply_name, date_modified
		          FROM __pages $where LIMIT 1";

		$this->db->query($query);
		return $this->db->result();
	}

	public function get_page_init($id){
		if(empty($this->all_pages))
			$this->get_pages();
		if(is_int($id) && array_key_exists(intval($id), $this->all_pages))
			return $page = $this->all_pages[intval($id)];
		elseif(is_string($id) || $id==''){
			foreach ($this->all_pages as $p){
				if ($p->url == $id)
					return $this->get_page_init((int)$p->id);
			}
		}
		return false;
	}

	/*
	*
	* Создание страницы
	*
	*/	
	public function add_page($page)
	{	
		$query = $this->db->placehold('INSERT INTO __pages SET ?%', $page);
		// echo $query; exit;
		if(!$this->db->query($query))
			return false;

		$id = $this->db->insert_id();
		$this->db->query("UPDATE __pages SET position=id WHERE id=?", $id);	
		return $id;
	}
	
	/*
	*
	* Обновить страницу
	*
	*/
	public function update_page($id, $page)
	{	
		$query = $this->db->placehold('UPDATE __pages SET ?% WHERE id in (?@)', $page, (array)$id);
		if(!$this->db->query($query))
			return false;
		return $id;
	}
	
	/*
	*
	* Удалить страницу
	*
	*/	
	public function delete_page($id)
	{
		if(!empty($id))
		{

			$blocks_images = array();

			$page = $this->pages->get_page(intval($id));
			if(!empty($page))
			{
				$page_blocks = unserialize($page->blocks);
				if(!empty($page_blocks))
				{
					foreach ($page_blocks as $pb) 
					{
						if(!empty($pb->images))
						{
							foreach ($pb->images as $img_name) 
							{
								$blocks_images[] = $img_name;
							}								
						}
					}
				}

				// Delete chains (for houses)
				if($page->menu_id == 5)
					$this->inventories->delete_items_chains(array('parent_id'=>$page->id, 'type'=>'house'));

			}
			if(!empty($blocks_images))
			{
				foreach($blocks_images as $i)
				{
					$file = pathinfo($i, PATHINFO_FILENAME);
					$ext = pathinfo($i, PATHINFO_EXTENSION);
					
					// Удалить все ресайзы
					$rezised_images = glob($this->config->root_dir.$this->resized_galleries_images_dir.$file.".*x*.".$ext);
					if(is_array($rezised_images))
					{
						foreach (glob($this->config->root_dir.$this->config->resized_galleries_images_dir.$file.".*x*.".$ext) as $f)
							@unlink($f);
					}
					@unlink($this->config->root_dir.$this->config->galleries_images_dir.$i);	
				}
			}



			$this->delete_image($id);
			$query = $this->db->placehold("DELETE FROM __pages WHERE id=? LIMIT 1", intval($id));
			if($this->db->query($query))
				return true;
		}
		return false;
	}	
	
	/*
	*
	* Функция возвращает массив меню
	*
	*/
	public function get_menus()
	{
		$menus = array();
		$query = "SELECT * FROM __menu ORDER BY position";
		$this->db->query($query);
		foreach($this->db->results() as $menu)
			$menus[$menu->id] = $menu;
		return $menus;
	}
	
	/*
	*
	* Функция возвращает меню по id
	* @param $id
	*
	*/
	public function get_menu($menu_id)
	{	
		$query = $this->db->placehold("SELECT * FROM __menu WHERE id=? LIMIT 1", intval($menu_id));
		$this->db->query($query);
		return $this->db->result();
	}
	
	// Удалить изображение
	public function delete_image($pages_ids){
		$pages_ids = (array) $pages_ids;
		$query = $this->db->placehold("SELECT image FROM __pages WHERE id in(?@)", $pages_ids);
		$this->db->query($query);
		$filenames = $this->db->results('image');
		if(!empty($filenames)){
			$query = $this->db->placehold("UPDATE __pages SET image=NULL WHERE id in(?@)", $pages_ids);
			$this->db->query($query);
			foreach($filenames as $filename){
				$query = $this->db->placehold("SELECT count(*) as count FROM __pages WHERE image=?", $filename);
				$this->db->query($query);
				$count = $this->db->result('count');
				if($count == 0){
					$file = pathinfo($filename, PATHINFO_FILENAME);
					$ext = pathinfo($filename, PATHINFO_EXTENSION);
			
					// Удалить все ресайзы
					$rezised_images = glob($this->config->root_dir.$this->config->resized_pages_images_dir.$file."*.".$ext);
					if(is_array($rezised_images))
						foreach (glob($this->config->root_dir.$this->config->resized_pages_images_dir.$file."*.".$ext) as $f)
							@unlink($f);

					@unlink($this->config->root_dir.$this->config->pages_images_dir.$filename);	
				}
			}	
		}
	}
	// Удалить изображение бекграунда
	public function delete_bg_image($pages_ids){
		$pages_ids = (array) $pages_ids;
		$query = $this->db->placehold("SELECT bg_image FROM __pages WHERE id in(?@)", $pages_ids);
		$this->db->query($query);
		$filenames = $this->db->results('bg_image');
		if(!empty($filenames)){
			$query = $this->db->placehold("UPDATE __pages SET bg_image=NULL WHERE id in(?@)", $pages_ids);
			$this->db->query($query);
			foreach($filenames as $filename){
				$query = $this->db->placehold("SELECT count(*) as count FROM __pages WHERE bg_image=?", $filename);
				$this->db->query($query);
				$count = $this->db->result('count');
				if($count == 0){
					@unlink($this->config->root_dir.$this->config->pages_bg_images_dir.$filename);	
				}
			}	
		}
	}
	
}
