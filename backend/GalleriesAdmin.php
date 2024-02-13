<?PHP 

require_once('api/Backend.php');

########################################
class GalleriesAdmin extends Backend
{

  public function fetch()
  {
	  
	$filter = array();
	$filter['page'] = max(1, $this->request->get('page', 'integer'));		
	$filter['limit'] = $this->settings->galleries_num_admin;
	  
	// Категории
	$categories = $this->galleries->get_categories_tree();
 	$this->design->assign('categories', $categories);
	
	// Текущая категория
	$category_id = $this->request->get('category_id', 'integer'); 
	if($category_id && $category = $this->galleries->get_category_i($category_id))
	  	$filter['category_id'] = $category->children;
		


   	// Обработка действий
  	if($this->request->method('post'))
  	{
		// Сортировка
		$positions = $this->request->post('positions'); 		
 		$ids = array_keys($positions);
		sort($positions);
		foreach($positions as $i=>$position)
			$this->galleries->update_gallery($ids[$i], array('position'=>$position)); 

		
		// Действия с выбранными
		$ids = $this->request->post('check');
		//print_r($ids); exit;
		if(is_array($ids))
		switch($this->request->post('action'))
		{
		    case 'disable':
		    {
				$this->galleries->update_gallery($ids, array('visible'=>0));	      
				break;
		    }
		    case 'enable':
		    {
				$this->galleries->update_gallery($ids, array('visible'=>1));	      
		        break;
		    }
		    case 'delete':
		    {
			    foreach($ids as $id)
					$this->galleries->delete_gallery($id);    
		        break;
		    }
			case 'move_to_page':
			{
				$target_page = $this->request->post('target_page', 'integer');
			    	
			    // Сразу потом откроем эту страницу
			    $filter['page'] = $target_page;
		
				// До какой галереи перемещать
				$limit = $filter['limit']*($target_page-1);
				if($target_page > $this->request->get('page', 'integer'))
					$limit += count($ids)-1;
				else
					$ids = array_reverse($ids, true);
		

				$temp_filter = $filter;
				$temp_filter['page'] = $limit+1;
				$temp_filter['limit'] = 1;
				$target_product = array_pop($this->galleries->get_galleries($temp_filter));
				$target_position = $target_product->position;
				   	
				// Если вылезли за последнюю галерею - берем позицию последней галереи в качестве цели перемещения
				if($target_page > $this->request->get('page', 'integer') && !$target_position)
				{
				    $query = $this->db->placehold("SELECT distinct g.position AS target FROM __galleries g LEFT JOIN __galleries_cat AS gc ON gc.gallery_id = g.id WHERE 1 $category_id_filter ORDER BY g.position DESC LIMIT 1", count($ids));	
				   	$this->db->query($query);
				   	$target_position = $this->db->result('target');
				}
				   	
			    foreach($ids as $id)
			    {		    	
				    $query = $this->db->placehold("SELECT position FROM __galleries WHERE id=? LIMIT 1", $id);	
				    $this->db->query($query);	      
				    $initial_position = $this->db->result('position');
		
				    if($target_position > $initial_position)
				    	$query = $this->db->placehold("	UPDATE __galleries set position=position-1 WHERE position>? AND position<=?", $initial_position, $target_position);	
				    else
				    	$query = $this->db->placehold("	UPDATE __galleries set position=position+1 WHERE position<? AND position>=?", $initial_position, $target_position);	
				    		
			    	$this->db->query($query);	      			    	
			    	$query = $this->db->placehold("UPDATE __galleries SET position = ? WHERE id = ?", $target_position, $id);	
			    	$this->db->query($query);	
				}
				
			    break;
			}
			case 'move_to_category':
			{
				$category_id = $this->request->post('target_category', 'integer');
				$filter['page'] = 1;
				$category = $this->galleries->get_category($category_id);
	  			$filter['category_id'] = $category->children;
			    	
			    foreach($ids as $id)
			    {
			    	$query = $this->db->placehold("DELETE FROM __galleries_cat WHERE category_id=? AND gallery_id=? LIMIT 1", $category_id, $id);	
			    	$this->db->query($query);	      			    	
			    	$query = $this->db->placehold("UPDATE IGNORE __galleries_cat set category_id=? WHERE gallery_id=? ORDER BY position DESC LIMIT 1", $category_id, $id);	
			    	$this->db->query($query);
			    	if($this->db->affected_rows() == 0)
						$query = $this->db->query("INSERT IGNORE INTO __galleries_cat set category_id=?, gallery_id=?", $category_id, $id);	
				}
			break;
			}
		}		
		
 	}

  

	// Отображение
	
	

	if(isset($category))
		$this->design->assign('category', $category);
		
	$galleries_count = $this->galleries->count_galleries($filter);
	// Показать все страницы сразу
	if($this->request->get('page') == 'all')
		$filter['limit'] = $galleries_count;
		
	if($filter['limit']>0)	  	
		$pages_count = ceil($galleries_count/$filter['limit']);
	else
		$pages_count = 0;
	$filter['page'] = min($filter['page'], $pages_count);
	$this->design->assign('products_count', $galleries_count);
	$this->design->assign('pages_count', $pages_count);
	$this->design->assign('current_page', $filter['page']);
	
	
  	$galleries = $this->galleries->get_galleries($filter);

 	$this->design->assign('galleries', $galleries);
	return $this->design->fetch('galleries.tpl');
  }
}


?>