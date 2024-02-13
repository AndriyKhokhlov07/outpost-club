<?php

 
require_once('api/Backend.php');

class AuthorsAdmin extends Backend
{
	public function fetch()
	{

		$filter = array();
		$filter['page'] = max(1, $this->request->get('page', 'integer')); 		
		$filter['limit'] = 20;

		// Текущий фильтр
		if($f = $this->request->get('filter', 'string'))
		{
			if($f == 'visible')
				$filter['visible'] = 1; 
			elseif($f == 'hidden')
				$filter['visible'] = 0;
			elseif($f == 'featured')
				$filter['featured'] = 1;
			$this->design->assign('filter', $f);
		}

		$authors_count = $this->blog->count_authors($filter);
		// Показать все страницы сразу
		if($this->request->get('page') == 'all')
			$filter['limit'] = $authors_count;


		// Обработка действий
		if($this->request->method('post'))
		{
			// Сортировка
			$positions = $this->request->post('positions');
	 		$ids = array_keys($positions);
			sort($positions);
			foreach($positions as $i=>$position)
				$this->blog->update_author($ids[$i], array('position'=>$position)); 

			// Действия с выбранными
			$ids = $this->request->post('check');
			if(is_array($ids))
			switch($this->request->post('action'))
			{
			    case 'disable':
			    {
			    	foreach($ids as $id)
						$this->blog->update_author($id, array('visible'=>0));	      
					break;
			    }
			    case 'enable':
			    {
			    	foreach($ids as $id)
						$this->blog->update_author($id, array('visible'=>1));	      
			        break;
			    }
			    case 'delete':
			    {
				    foreach($ids as $id)
						$this->blog->delete_author($id);    
			        break;
			    }
				case 'move_to_page':
			    {
		
			    	$target_page = $this->request->post('target_page', 'integer');
			    	
			    	// Сразу потом откроем эту страницу
			    	$filter['page'] = $target_page;
		
				    // До какой записи перемещать
				    $limit = $filter['limit']*($target_page-1);
				    if($target_page > $this->request->get('page', 'integer'))
				    	$limit += count($ids)-1;
				    else
				    	$ids = array_reverse($ids, true);
		

					$temp_filter = $filter;
					$temp_filter['page'] = $limit+1;
					$temp_filter['limit'] = 1;
					$target_author = array_pop($this->blog->get_authors_list($temp_filter));
					$target_position = $target_author->position;
				   	
				   	// Если вылезли за последнюю запись - берем позицию последней записи в качестве цели перемещения
					if($target_page > $this->request->get('page', 'integer') && !$target_position)
					{
				    	$query = $this->db->placehold("SELECT distinct s.position AS target FROM __authors s ORDER BY s.position DESC LIMIT 1", count($ids));	
				   		$this->db->query($query);
				   		$target_position = $this->db->result('target');
					}
				   	
			    	foreach($ids as $id)
			    	{		    	
				    	$query = $this->db->placehold("SELECT position FROM __authors WHERE id=? LIMIT 1", $id);	
				    	$this->db->query($query);	      
				    	$initial_position = $this->db->result('position');
		
				    	if($target_position > $initial_position)
				    		$query = $this->db->placehold("	UPDATE __authors set position=position-1 WHERE position>? AND position<=?", $initial_position, $target_position);	
				    	else
				    		$query = $this->db->placehold("	UPDATE __authors set position=position+1 WHERE position<? AND position>=?", $initial_position, $target_position);	
				    		
			    		$this->db->query($query);	      			    	
			    		$query = $this->db->placehold("UPDATE __authors SET __authors.position = ? WHERE __authors.id = ?", $target_position, $id);	
			    		$this->db->query($query);	
				    }
			        break;
				}
			}				
		}

		
		
		$authors = array();
		foreach($this->blog->get_authors_list($filter) as $a)
			$authors[$a->id] = $a;
		if(!empty($authors))
		{
			$authors = $this->blog->get_authors(array('author_id'=>array_keys($authors)));
		}
		
		$this->design->assign('authors_count', $authors_count);
		$this->design->assign('pages_count', ceil($authors_count/$filter['limit']));
		$this->design->assign('current_page', $filter['page']);
		$this->design->assign('authors', $authors);

		return $this->design->fetch('blog/authors.tpl');
	}
}
