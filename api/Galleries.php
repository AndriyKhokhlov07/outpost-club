<?php

// @copyright	2015 Dmitriy Kozik

require_once('Backend.php');

class Galleries extends Backend
{
	

	/*----- Категрии галерей -----*/

	
	public $all_categories;

	// Массив категорий
	public function get_categories($filter = array())
	{
		$parent_id_filter = '';
		$visible_filter = '';
		$categories = array();
		
		if(isset($filter['parent_id']))
			$parent_id_filter = $this->db->placehold('AND parent_id=?', (int)$filter['parent_id']);

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND visible = ?', intval($filter['visible']));
		
		$query = $this->db->placehold("SELECT 
						id,
						parent_id,
						name,
						description,
						url,
						meta_title,
						meta_keywords,
						meta_description,
						visible,
						position
					FROM __galleries_categories
					WHERE 1 $parent_id_filter $visible_filter 
					ORDER BY position");
		
		$this->db->query($query);
		
		foreach($this->db->results() as $category)
			$categories[$category->id] = $category;
			
		$this->categories_tree->get_categories_tree('galleries_categories', $categories);
			
		return $categories;
	}
	
	// Древо категорий
	public function get_categories_tree()
	{
		if(!isset($this->categories_tree->categories_tree['galleries_categories']))
			$this->get_categories();	
		return $this->categories_tree->categories_tree['galleries_categories'];
	}
	
	// Категория
	public function get_category_i($id)
	{
		if(!isset($this->all_categories))
			$this->get_categories();
		if(is_int($id) && array_key_exists(intval($id), $this->all_categories))
			return $category = $this->all_categories[intval($id)];
		elseif(is_string($id))
			foreach ($this->all_categories as $category)
				if ($category->url == $id)
					return $this->get_category_i((int)$category->id);	
		
		return false;
	}
	
	public function get_category($id)
	{
		if(gettype($id) == 'string')
			$where = $this->db->placehold(' WHERE url=? ', $id);
		else
			$where = $this->db->placehold(' WHERE id=? ', intval($id));
		
		$query = $this->db->placehold("SELECT
						id,
						parent_id,
						name,
						description,
						url,
						meta_title,
						meta_keywords,
						meta_description,
						visible,
						position
					FROM __galleries_categories
					$where 
					LIMIT 1");

		$this->db->query($query);
		return $this->db->result();
	}
	
	
	// Добавление категории
	public function add_category($category)
	{	
		$query = $this->db->placehold('INSERT INTO __galleries_categories SET ?%', $category);
		//echo $query; exit;
		if(!$this->db->query($query))
			return false;

		$id = $this->db->insert_id();
		$this->db->query("UPDATE __galleries_categories SET position=id WHERE id=?", $id);	
		return $id;
	}
	
	// Обновление категории
	public function update_category($id, $category)
	{	
		$query = $this->db->placehold('UPDATE __galleries_categories SET ?% WHERE id in (?@)', $category, (array)$id);
		if(!$this->db->query($query))
			return false;
		return $id;
	}
	
	// Удаление категории
	public function delete_category($id)
	{
		if(!empty($id))
		{
			$query = $this->db->placehold("DELETE FROM __galleries_categories WHERE id=? LIMIT 1", intval($id));
			if($this->db->query($query))
				return true;
		}
		return false;
	}
	/*----- Категрии галерей (End) -----*/
	
	

	
	/*----- Галереи -----*/
	
	// Все галереи
	public function get_galleries($filter = array())
	{		
		// По умолчанию
		$limit = 1000;
		$page = 1;
		$category_id_filter = '';
		$gallery_id_filter = '';
		$visible_filter = '';
		$group_by = '';
		$order = 'g.position DESC';

		if(isset($filter['limit']))
			$limit = max(1, intval($filter['limit']));

		if(isset($filter['page']))
			$page = max(1, intval($filter['page']));

		$sql_limit = $this->db->placehold(' LIMIT ?, ? ', ($page-1)*$limit, $limit);

		if(!empty($filter['id']))
			$gallery_id_filter = $this->db->placehold('AND g.id in(?@)', (array)$filter['id']);

		if(!empty($filter['category_id']))
		{
			$category_id_filter = $this->db->placehold('INNER JOIN __galleries_cat gc ON gc.gallery_id = g.id AND gc.category_id in(?@)', (array)$filter['category_id']);
			$group_by = "GROUP BY g.id";
		}
		
		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND g.visible=?', intval($filter['visible']));
			
		$query = "SELECT  
					g.id,
					g.url,
					g.name,
					g.meta_title, 
					g.meta_keywords, 
					g.meta_description,
					g.annotation,
					g.body,
					g.position,
					g.visible 
				FROM __galleries g		
				$category_id_filter 
				WHERE 
					1
					$gallery_id_filter
					$visible_filter
				$group_by
				ORDER BY g.position
					$sql_limit";
		$this->db->query($query);

		return $this->db->results();
	}
	
	// Кол-во галерей
	public function count_galleries($filter = array())
	{
		$category_id_filter = '';
		$gallery_id_filter = '';
		$visible_filter = '';
		
		if(!empty($filter['id']))
			$gallery_id_filter = $this->db->placehold('AND g.id in(?@)', (array)$filter['id']);

		if(!empty($filter['category_id']))
		{
			$category_id_filter = $this->db->placehold('INNER JOIN __galleries_cat gc ON gc.gallery_id = g.id AND gc.category_id in(?@)', (array)$filter['category_id']);
			$group_by = "GROUP BY p.id";
		}
		
		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND g.visible=?', intval($filter['visible']));
			
		$query = "SELECT count(distinct g.id) as count
				FROM __galleries AS g
				$category_id_filter
				WHERE 1
					$gallery_id_filter
					$visible_filter ";

		$this->db->query($query);	
		return $this->db->result('count');
	}
	
	// Галерея
	public function get_gallery($id)
	{
		if(gettype($id) == 'string')
			$where = $this->db->placehold(' WHERE url=? ', $id);
		else
			$where = $this->db->placehold(' WHERE id=? ', intval($id));
		
		$query = "SELECT id, url, name, meta_title, meta_description, meta_keywords, annotation, body, position, visible
		          FROM __galleries $where LIMIT 1";

		$this->db->query($query);
		return $this->db->result();
	}
	
	// К катим категориям принадлежит галерея
	function get_gallery_categories($id)
	{
		$query = $this->db->placehold("SELECT gc.category_id as category_id FROM __galleries_cat gc
										WHERE gc.gallery_id = ?", $id);
		$this->db->query($query);
		//return $this->db->results('category_id');
		return $this->db->results();	
	}
	
	public function add_gallery_category($id, $category_id)
	{
		$query = $this->db->placehold("INSERT IGNORE INTO __galleries_cat SET gallery_id=?, category_id=?", $id, $category_id);
		$this->db->query($query);
	}
			
	public function update_gallery_categories($id, $categories)
	{
		$id = intval($id);
		$query = $this->db->placehold("DELETE FROM __galleries_cat WHERE gallery_id=?", $id);
		$this->db->query($query);
		
		if(is_array($categories))
		{
			$values = array();
			foreach($categories as $category)
				$values[] = "($id , ".intval($category).")";
	
			$query = $this->db->placehold("INSERT INTO __galleries_cat (gallery_id, category_id) VALUES ".implode(', ', $values));
			$this->db->query($query);
		}
	}
	
	// Создание галереи
	public function add_gallery($gallery)
	{	
		$query = $this->db->placehold('INSERT INTO __galleries SET ?%', $gallery);
		if(!$this->db->query($query))
			return false;

		$id = $this->db->insert_id();
		$this->db->query("UPDATE __galleries SET position=id WHERE id=?", $id);	
		return $id;
	}
	
	// Обновление галереи
	public function update_gallery($id, $gallery)
	{	
		$query = $this->db->placehold('UPDATE __galleries SET ?% WHERE id in (?@)', $gallery, (array)$id);
		if(!$this->db->query($query))
			return false;
		return $id;
	}
	
	// Удаление галереи
	public function delete_gallery($id)
	{
		if(!empty($id))
		{
			$query = $this->db->placehold("DELETE FROM __galleries WHERE id=? LIMIT 1", intval($id));
			$this->db->query($query);
			$query = $this->db->placehold("DELETE FROM __galleries_cat WHERE gallery_id=?", intval($id));
			$this->db->query($query);
			// Удаляем изображения
			foreach($this->get_images(array('gallery_id'=>$id)) as $i){
				$this->delete_image($i->id);
			}
		}
	}
	/*----- Галереи (End) -----*/
	
	
	
	
	/*----- Изображения -----*/
	

	// Изображения
	function get_images($filter = array())
	{
		$id_filter = '';
		$gallery_id_filter = '';
		$main_filter = '';
		
		if(!empty($filter['id']))
			$id_filter = $this->db->placehold('AND i.id in(?@)', (array)$filter['id']);
		if(!empty($filter['gallery_id']))
			$gallery_id_filter = $this->db->placehold('AND i.gallery_id in(?@)', (array)$filter['gallery_id']);
			
		if(isset($filter['main']))
			$main_filter = $this->db->placehold('AND i.main=?', intval($filter['main']));

		$query = $this->db->placehold("SELECT i.id, i.gallery_id, i.name, i.annotation, i.filename, i.main, i.position
									FROM __gallery_images AS i WHERE 1 $id_filter $gallery_id_filter $main_filter ORDER BY i.gallery_id, i.position");
		$this->db->query($query);
		return $this->db->results();
	}
	
	// Изображение
	public function get_image($id)
	{
		if(empty($id))
			return false;
		
		$query = $this->db->placehold("SELECT i.id, i.gallery_id, i.name, i.annotation, i.filename, i.main
		          FROM __gallery_images AS i WHERE id=? LIMIT 1", intval($id));
				  
		$this->db->query($query);
		return $this->db->result();
	}
	
	// Добавить изображение
	
	public function add_image($image)
	{	
		$query = $this->db->placehold('INSERT INTO __gallery_images SET ?%', $image);
		if(!$this->db->query($query))
			return false;

		$id = $this->db->insert_id();
		$this->db->query("UPDATE __gallery_images SET position=id WHERE id=?", $id);	
		return $id;
	}
	
	// Обновить изображение
	public function update_image($id, $image)
	{
	
		$query = $this->db->placehold("UPDATE __gallery_images SET ?% WHERE id=?", $image, $id);
		$this->db->query($query);
		
		return($id);
	}
	
	// Удалить страницу изображения
	public function delete_image($id)
	{
		if(!empty($id))
		{
			// Удаляем изображение
			$this->delete_image_file($id);
			// Удаляем страницу
			$query = $this->db->placehold("DELETE FROM __gallery_images WHERE id=? LIMIT 1", intval($id));
			$this->db->query($query);
		}
	}
	
	// Удалить изображение
	public function delete_image_file($id)
	{
		$query = $this->db->placehold("SELECT filename FROM __gallery_images WHERE id=?", intval($id));
		$this->db->query($query);
		$filename = $this->db->result('filename');
		if(!empty($filename))
		{
			$query = $this->db->placehold("UPDATE __gallery_images SET filename=NULL WHERE id=?", $id);
			$this->db->query($query);
			$query = $this->db->placehold("SELECT count(*) as count FROM __gallery_images WHERE filename=? LIMIT 1", $filename);
			$this->db->query($query);
			$count = $this->db->result('count');
			if($count == 0)
			{
				$file = pathinfo($filename, PATHINFO_FILENAME);
				$ext = pathinfo($filename, PATHINFO_EXTENSION);
				
				// Удалить все ресайзы
				$rezised_images = glob($this->config->root_dir.$this->resized_galleries_images_dir.$file.".*x*.".$ext);
				if(is_array($rezised_images))
				{
					foreach (glob($this->config->root_dir.$this->config->resized_galleries_images_dir.$file.".*x*.".$ext) as $f)
						@unlink($f);
				}
				@unlink($this->config->root_dir.$this->config->galleries_images_dir.$filename);	
			}
		}
	}
	
	/*----- Изображения (End) -----*/
	
	
	/*----- Связанные товары и услуги -----*/
	
	public function get_related($filter = array())
	{
		$type_filter = '';
		$image_id_filter = '';
		$related_id_filter = ''; 
		
		if(!empty($filter['image_id']))
			$image_id_filter = $this->db->placehold('AND image_id in(?@)', (array)$filter['image_id']);
		
		if(!empty($filter['related_id']))
			$related_id_filter = $this->db->placehold('AND related_id in(?@)', (array)$filter['related_id']);
			
		
		if(empty($image_id_filter) && empty($related_id_filter))
			return array();
				
		$query = $this->db->placehold("SELECT 
						image_id, 
						related_id,
						type,
						position
					FROM __related_galleries
					WHERE 1
						$image_id_filter
						$related_id_filter
						$type_filter 
					ORDER BY position       
					");
		$this->db->query($query);
		return $this->db->results();
	}
	
	// Добавление связанного товара или услуг
	public function add_related($image_id, $related_id, $type, $position=0)
	{
		if($type == 'products') $type = 1;
		elseif($type == 'services') $type = 2;
		
		$query = $this->db->placehold("INSERT INTO __related_galleries SET image_id=?, related_id=?, type=?, position=?", $image_id, $related_id, $type, $position);
		$this->db->query($query);
		return $related_id;
	}
	
	// Удаление связанного товара или услуги
	public function delete_related($filter = array())
	{
		$type_filter = '';
		$image_id_filter = '';
		$related_id_filter = '';
		
		if(!empty($filter['image_id']))
			$image_id_filter = $this->db->placehold('image_id=?', intval($filter['image_id']));
			
		if(!empty($filter['related_id']))
		{
			$related_id_filter = $this->db->placehold('related_id=?', (array)$filter['related_id']);
			if(!empty($image_id_filter))
				$related_id_filter = 'AND '.$related_id_filter;
			
		}

		//if(empty($image_id_filter) || (empty($related_id_filter) && empty($type_filter)))
		//	return false;
		
		$query = $this->db->placehold("DELETE FROM __related_galleries WHERE $image_id_filter $related_id_filter $type_filter");
		$this->db->query($query);
	}
	
	
	
	/*----- Связанные товары и услуги (End) -----*/
	
}