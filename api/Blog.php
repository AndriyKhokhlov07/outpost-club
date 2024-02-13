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

class Blog extends Backend
{

// TAGS
	public function get_tags($filter = array()){
		$url_filter = '';
		$post_id_filter = '';
		$category_id_filter = '';
		$by_tag_id_filter = '';
		$is_featured_filter = '';
		$in_filter_filter = '';
		$visible_filter = '';
		$posts_count = '';
		$group_by = '';
		$limit = '';

		if(isset($filter['url']))
		{
			$url_filter = $this->db->placehold('AND t.url=?', $filter['url']);
			$filter['limit'] = 1;
		}

		if(isset($filter['limit']))
			$limit = $this->db->placehold('LIMIT ?', (int)$filter['limit']);

		if(isset($filter['featured']))
			$is_featured_filter = $this->db->placehold('AND t.featured=?', intval($filter['featured']));

		if(isset($filter['in_filter']))
			$in_filter_filter = $this->db->placehold('AND t.in_filter=?', intval($filter['in_filter']));
			
		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND t.visible=?', intval($filter['visible']));

		if(!empty($filter['post_id']))
		{
			$post_id_filter = $this->db->placehold('INNER JOIN __posts_tags pt ON pt.tag_id = t.id AND pt.post_id in(?@)', (array)$filter['post_id']);
			$group_by = "GROUP BY t.id";
		}

		if(!empty($filter['by_tag_id']))
		{
			$by_tag_id_filter = $this->db->placehold("
							INNER JOIN __posts_tags pt ON pt.tag_id=t.id 
							INNER JOIN __posts_tags tt ON tt.post_id=pt.post_id AND tt.tag_id in(?@)", (array)$filter['by_tag_id']);
			$group_by = 'GROUP BY t.id';
		}
		
		$query = $this->db->placehold("SELECT
								t.id,  
								t.url, 
								t.image,
								t.related_posts,
								t.featured,
								t.in_filter,
								t.visible, 
								t.position,
								t.name, 
								t.description,
								t.meta_title,
								t.meta_description
							FROM __blog_tags t	
								$post_id_filter
							WHERE 
								1
								$visible_filter
								$url_filter
								$by_tag_id_filter
							$group_by
							ORDER BY t.position
							$limit");

		if(!empty($filter['posts_count']))
		{
			$group_by = 'GROUP BY t.id';
			$query = $this->db->placehold("SELECT 
								t.id, 
								t.url, 
								t.image,
								t.related_posts,
								t.featured,
								t.in_filter,
								t.visible, 
								t.position,
								t.name, 
								t.description,
								t.meta_title,
								t.meta_description,
								COUNT(pp.id) as posts_count
		                    FROM __blog_tags t 
		                    	$post_id_filter
		                    LEFT JOIN __posts_tags pt ON pt.tag_id=t.id 
		                    LEFT JOIN __blog p ON p.id=pt.post_id AND p.visible 
		                    WHERE 
								1
								$visible_filter
		                       	$url_filter
								$by_tag_id_filter

							$group_by
		                    ORDER BY t.position
		                    $limit");
		}
										
		$this->db->query($query);

		if(isset($filter['limit']) && $filter['limit'] == 1)
			return $this->db->result();
		else
			return $this->db->results();
	}

	public function get_tags_list($filter = array())
	{
		$post_id_filter = '';
		$is_featured_filter = '';
		$visible_filter = '';
		$group_by = '';

		if(isset($filter['featured']))
			$is_featured_filter = $this->db->placehold('AND t.featured=?', intval($filter['featured']));

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND t.visible=?', intval($filter['visible']));

		if(!empty($filter['post_id']))
		{
			$post_id_filter = $this->db->placehold('INNER JOIN __posts_tags pt ON pt.tag_id = t.id AND pt.post_id in(?@)', (array)$filter['post_id']);
			$group_by = "GROUP BY t.id";
		}

		$query = $this->db->placehold("SELECT 
								t.id, 
								t.name,
								t.url, 
								t.image, 
								t.related_posts,
								t.featured,
								t.in_filter,
								t.visible, 
								t.position
							FROM __blog_tags t
								$post_id_filter
							WHERE 
								1
								$is_featured_filter
								$visible_filter
							$group_by
							ORDER BY t.position");
		$this->db->query($query);
		return $this->db->results();
	}


	public function get_tag($id){
		if(is_int($id))
			$query = $this->db->placehold("SELECT id, name, description, meta_title, meta_description, url, featured, in_filter, image, related_posts, visible, position FROM __blog_tags WHERE id=? LIMIT 1", $id);
		else
			$query = $this->db->placehold("SELECT id, name, description, meta_title, meta_description, url, featured, in_filter, image, related_posts, visible, position FROM __blog_tags WHERE url=? LIMIT 1", $id);
		$this->db->query($query);
		return $this->db->result();
	}

	// public function get_tags_content($filter = array()){
	// 	$tag_id_filter = '';
		
	// 	if(!empty($filter['tag_id']))
	// 		$tag_id_filter = $this->db->placehold('AND tc.tag_id in(?@)', (array)$filter['tag_id']);
		
	// 	$query = $this->db->placehold("SELECT
	// 					tc.id as content_id,
	// 					tc.tag_id,
	// 					tc.language_id,
	// 					tc.name, 
	// 					tc.description,
	// 					tc.meta_title,
	// 					tc.meta_description
	// 				FROM __blog_tags_content tc
	// 				WHERE 
	// 					1
	// 					$tag_id_filter
	// 				ORDER BY tc.language_id");
		
	// 	$this->db->query($query);	
	// 	return $this->db->results();
	// }

	// Добавление тега
	public function add_tag($tag)
	{
		$tag = (array)$tag;
		if(empty($tag['url']))
		{
			$tag['url'] = preg_replace("/[\s]+/ui", '_', $tag['name']);
			$tag['url'] = strtolower(preg_replace("/[^0-9a-zа-я_]+/ui", '', $tag['url']));
		}
		// Если есть тег с таким URL, добавляем к нему число
		while($this->get_tag((string)$tag['url']))
		{
			if(preg_match('/(.+)_([0-9]+)$/', $tag['url'], $parts))
				$tag['url'] = $parts[1].'_'.($parts[2]+1);
			else
				$tag['url'] = $tag['url'].'_2';
		}
		$this->db->query("INSERT INTO __blog_tags SET ?%", $tag);
		$id = $this->db->insert_id();
		$this->db->query("UPDATE __blog_tags SET position=id WHERE id=?", $id);
		return $id;
	}
	// public function add_tag_content($tag_content){
	// 	$this->db->query("INSERT INTO __blog_tags_content SET ?%", $tag_content);
	// 	$id = $this->db->insert_id();		
	// 	return $id;
	// }

	// Изменение тега
	public function update_tag($id, $tag)
	{
		$query = $this->db->placehold("UPDATE __blog_tags SET ?% WHERE id=? LIMIT 1", $tag, intval($id));
		$this->db->query($query);
		return intval($id);
	}
	// public function update_tag_content($id, $tag_content)
	// {
	// 	$query = $this->db->placehold("UPDATE __blog_tags_content SET ?% WHERE id=? LIMIT 1", $tag_content, intval($id));
	// 	$this->db->query($query);	
	// 	return intval($id);
	// }

	// Удаление тега
	public function delete_tag($ids)
	{
		$ids = (array)$ids;

		foreach($ids as $id)
		{
			if($tag = $this->get_tag(intval($id)))
				$this->delete_tag_image($tag->id);
			if(!empty($tag))
			{
				$query = $this->db->placehold("DELETE FROM __blog_tags WHERE id in(?@)", (array)$tag->id);
				$this->db->query($query);
				$this->delete_tag_content('tag', $tag->id);
				$query = $this->db->placehold('DELETE FROM __posts_tags WHERE tag_id in(?@)', (array)$tag->id);
	   	    	$this->db->query($query);
			}
		}	
		return $id;
	}
	
	// public function delete_tag_content($type, $ids)
	// {
	// 	$ids = (array) $ids;
	// 	if($type == 'content')
	// 		$query = $this->db->placehold("DELETE FROM __blog_tags_content WHERE id in(?@)", $ids);
	// 	elseif($type == 'tag')
	// 		$query = $this->db->placehold("DELETE FROM __blog_tags_content WHERE tag_id in(?@)", $ids);
	// 	$this->db->query($query);	
	// 	return $id;
	// }

	// Удалить изображение тега
	public function delete_tag_image($tags_ids)
	{
		$tags_ids = (array) $tags_ids;
		$query = $this->db->placehold("SELECT image FROM __blog_tags WHERE id in(?@)", $tags_ids);
		$this->db->query($query);
		$filenames = $this->db->results('image');
		if(!empty($filenames))
		{
			$query = $this->db->placehold("UPDATE __blog_tags SET image=NULL WHERE id in(?@)", $tags_ids);
			$this->db->query($query);
			foreach($filenames as $filename)
			{
				$query = $this->db->placehold("SELECT count(*) as count FROM __blog_tags WHERE image=?", $filename);
				$this->db->query($query);
				$count = $this->db->result('count');
				if($count == 0)
				{			
					$file = pathinfo($filename, PATHINFO_FILENAME);
					$ext = pathinfo($filename, PATHINFO_EXTENSION);
			
					$rezised_images = glob($this->config->root_dir.$this->config->resized_blog_tags_images_dir.$file.".*x*.".$ext);
					if(is_array($rezised_images))
					foreach (glob($this->config->root_dir.$this->config->resized_blog_tags_images_dir.$file.".*x*.".$ext) as $f)
						@unlink($f);
					@unlink($this->config->root_dir.$this->config->blog_tags_images_dir.$filename);		
				}
			}	
		}
	}


	public function get_posts_tags($filter = array())
	{
		$post_id_filter = '';
		$tag_id_filter = '';

		if(!empty($filter['post_id']))
			$post_id_filter = $this->db->placehold('AND post_id in(?@)', (array)$filter['post_id']);

		if(!empty($filter['tag_id']))
			$tag_id_filter = $this->db->placehold('AND tag_id in(?@)', (array)$filter['tag_id']);

		$query = $this->db->placehold("SELECT 
							post_id,
							tag_id,
							position 
						FROM __posts_tags 
						WHERE 1
							$post_id_filter
							$tag_id_filter
						ORDER BY position");
		$this->db->query($query);
		return $this->db->results();
	}

	// Добавить тег к заданной записи
	public function add_post_tag($post_id, $tag_id, $position=0)
	{
		$query = $this->db->placehold("INSERT IGNORE INTO __posts_tags SET post_id=?, tag_id=?, position=?", $post_id, $tag_id, $position);
		$this->db->query($query);
	}

	// Удалить тег заданной записи
	public function delete_post_tag($post_id, $tag_id)
	{
		$query = $this->db->placehold("DELETE FROM __posts_tags WHERE post_id=? AND tag_id=? LIMIT 1", intval($post_id), intval($tag_id));
		$this->db->query($query);
	}





	
	// AUTHORS

	public function get_authors($filter = array()){
		
		$limit = 100;
		$page = 1;
		$author_id_filter = '';
		$url_filter = '';
		$post_id_filter = '';
		$tag_id_filter = '';
		$is_featured_filter = '';
		$visible_filter = '';
		$group_by = '';
		$order_by = 'ORDER BY a.position';
		//$limit = '';


		if(isset($filter['url']))
		{
			$url_filter = $this->db->placehold('AND a.url=?', $filter['url']);
			$filter['limit'] = 1;
		}
		
		if(isset($filter['limit']))
			$limit = max(1, intval($filter['limit']));

		if(isset($filter['page']))
			$page = max(1, intval($filter['page']));

		$sql_limit = $this->db->placehold(' LIMIT ?, ? ', ($page-1)*$limit, $limit);

		if(!empty($filter['id']))
			$author_id_filter = $this->db->placehold('AND a.id in(?@)', (array)$filter['id']);

		if(!empty($filter['post_id']))
		{
			$post_id_filter = $this->db->placehold('INNER JOIN __posts_authors ps ON ps.author_id = a.id AND ps.post_id in(?@)', (array)$filter['post_id']);
			$group_by = "GROUP BY a.id";
			$order_by = 'ORDER BY ps.position';
		}


		

		if(!empty($filter['tag_id']))
		{
			$tag_id_filter = $this->db->placehold("
							INNER JOIN __posts_authors ppa ON ppa.author_id = a.id
							INNER JOIN __posts_tags pt ON pt.post_id=ppa.post_id AND pt.tag_id in(?@)", (array)$filter['tag_id']);
			$group_by = 'GROUP BY a.id';
		}

		$select_posts_count = '';
		$posts_count = '';
		if(isset($filter['posts_count']))
		{
			$tag_join = '';
			$select_posts_count = $this->db->placehold(', COUNT(pa.author_id) as posts_count');
			if(!empty($filter['tag_id']))
			{
				$tag_join = $this->db->placehold("INNER JOIN __posts_tags ptt ON ptt.post_id=pa.post_id AND ptt.tag_id in(?@)", (array)$filter['tag_id']);
			}
			$posts_count = $this->db->placehold("
							LEFT JOIN __posts_authors pa ON pa.author_id = a.id
							INNER JOIN __posts p ON p.id = pa.post_id AND p.visible = 1
							$tag_join
				");
			$group_by = "GROUP BY a.id";
			$order_by = 'ORDER BY posts_count DESC';
		}

		if(isset($filter['featured']))
			$is_featured_filter = $this->db->placehold('AND a.featured=?', intval($filter['featured']));

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND a.visible = ?', intval($filter['visible']));
		
		$query = $this->db->placehold("SELECT
											a.id, 
											a.url,
											a.image, 
											a.featured,
											a.visible, 
											a.position,
											-- ac.id as content_id,
											a.name,
											a.post,
											a.text
										FROM __authors a
											$tag_id_filter
											$posts_count
											$post_id_filter
										WHERE 1 
											$author_id_filter
											$url_filter
											$is_featured_filter
											$visible_filter
										$group_by
										$order_by
										$sql_limit");

		$this->db->query($query);

		if(isset($filter['limit']) && $filter['limit'] == 1)
			return $this->db->result();
		else
			return $this->db->results();
	}


	
	// Функция возвращает количество авторов
	public function count_authors($filter = array()){
		$author_id_filter = '';
		$is_featured_filter = '';
		$visible_filter = '';

		if(!empty($filter['id']))
			$author_id_filter = $this->db->placehold('AND a.id in(?@)', (array)$filter['id']);

		if(isset($filter['featured']))
			$is_featured_filter = $this->db->placehold('AND a.featured=?', intval($filter['featured']));

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND a.visible = ?', intval($filter['visible']));
		
		$query = $this->db->placehold("SELECT
											count(distinct a.id) as count
										FROM __authors a
										WHERE 1 
											$author_id_filter
											$is_featured_filter
											$visible_filter");						
		$this->db->query($query);
		return $this->db->result('count');
	}
	
	
	public function get_authors_list($filter = array()){
		
		$id_filter = '';
		$is_featured_filter = '';
		$visible_filter = '';

		if(isset($filter['id']))
			$id_filter = $this->db->placehold('AND id in (?@)', (array)$filter['id']);

		if(isset($filter['featured']))
			$is_featured_filter = $this->db->placehold('AND featured=?', intval($filter['featured']));

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND visible = ?', intval($filter['visible']));
		
		$query = $this->db->placehold("SELECT 
						id, 
						url,
						name,
						post,
						image, 
						featured,
						visible, 
						position 
					FROM __authors 
					WHERE 1 
						$id_filter 
						$is_featured_filter
						$visible_filter 
					ORDER BY position");
		$this->db->query($query);
		return $this->db->results();
	}	
	
	// public function get_authors_content($filter = array()){
	// 	$author_id_filter = '';
		
	// 	if(!empty($filter['author_id']))
	// 		$author_id_filter = $this->db->placehold('AND ac.author_id in(?@)', (array)$filter['author_id']);

		
	// 	$query = $this->db->placehold("SELECT
	// 					ac.id as content_id,
	// 					ac.author_id,
	// 					ac.language_id,
	// 					ac.name, 
	// 					ac.post,
	// 					ac.text
	// 				FROM __authors_content ac
	// 				WHERE 
	// 					1
	// 					$author_id_filter
	// 				ORDER BY ac.language_id");
		
	// 	$this->db->query($query);	
	// 	return $this->db->results();
	// }

	public function get_author($id){
		if(is_int($id))
			$query = $this->db->placehold("SELECT * FROM __authors WHERE id=? LIMIT 1", $id);
		else
			$query = $this->db->placehold("SELECT * FROM __authors WHERE url=? LIMIT 1", $id);

		$this->db->query($query);
		return $this->db->result();
	}
	
	// public function get_content_author($filter = array()){
	// 	$author_id_filter = '';
	// 	$language_id_filter = '';
		
	// 	if(!empty($filter['author_id']))
	// 		$author_id_filter = $this->db->placehold('AND ac.author_id=? ', $filter['author_id']);
			
	// 	if(!empty($filter['language_id']))
	// 		$language_id_filter = $this->db->placehold('AND ac.language_id=? ', $filter['language_id']);

	// 	$query = $this->db->placehold("SELECT
	// 					ac.id as content_id,
	// 					ac.author_id,
	// 					ac.language_id,
	// 					ac.name,
	// 					ac.post,
	// 					ac.text
	// 				FROM __authors_content ac
	// 				WHERE 1
	// 					$author_id_filter
	// 					$language_id_filter
	// 				LIMIT 1");
					
	// 	$this->db->query($query);	
	// 	return $this->db->result();
	// }
	
	
	public function add_author($author)
	{
		$author = (array)$author;

		while($this->get_author((string)$author['url']))
		{
			if(preg_match('/(.+)_([0-9]+)$/', $author['url'], $parts))
				$author['url'] = $author[1].'_'.($parts[2]+1);
			else
				$author['url'] = $author['url'].'_2';
		}

		$this->db->query("INSERT INTO __authors SET ?%", $author);
		$id = $this->db->insert_id();
		$this->db->query("UPDATE __authors SET position=id WHERE id=?", $id);				
		return $id;
	}
	
	// public function add_content_author($content_author){
	// 	$this->db->query("INSERT INTO __authors_content SET ?%", $content_author);
	// 	$id = $this->db->insert_id();			
	// 	return $id;
	// }
	
	public function update_author($id, $author)
	{
		$query = $this->db->placehold("UPDATE __authors SET ?% WHERE id=? LIMIT 1", $author, intval($id));
		$this->db->query($query);	
		return intval($id);
	}
	// public function update_content_author($id, $content_author)
	// {
	// 	$query = $this->db->placehold("UPDATE __authors_content SET ?% WHERE id=? LIMIT 1", $content_author, intval($id));
	// 	$this->db->query($query);	
	// 	return intval($id);
	// }
	
	public function delete_author($id)
	{
		$query = $this->db->placehold("DELETE FROM __posts_authors WHERE author_id=?", intval($id));
		$this->db->query($query);

		$this->delete_author_image($id);
		$query = $this->db->placehold("DELETE FROM __authors WHERE id=?", intval($id));
		$this->db->query($query);
		$this->delete_content_author('author', intval($id));	
		return $id;
	}
	
	// public function delete_content_author($type, $ids){
	// 	$ids = (array) $ids;
	// 	if($type == 'content')
	// 		$query = $this->db->placehold("DELETE FROM __authors_content WHERE id in(?@)", $ids);
	// 	elseif($type == 'author')
	// 		$query = $this->db->placehold("DELETE FROM __authors_content WHERE author_id in(?@)", $ids);
	// 	$this->db->query($query);
	// 	if(!empty($id))		
	// 		return $id;
	// }
	
	// Удалить изображение
	public function delete_author_image($authors_ids)
	{
		$authors_ids = (array) $authors_ids;
		$query = $this->db->placehold("SELECT image FROM __authors WHERE id in(?@)", $authors_ids);
		$this->db->query($query);
		$filenames = $this->db->results('image');
		if(!empty($filenames))
		{
			$query = $this->db->placehold("UPDATE __authors SET image=NULL WHERE id in(?@)", $authors_ids);
			$this->db->query($query);
			foreach($filenames as $filename)
			{
				$query = $this->db->placehold("SELECT count(*) as count FROM __authors WHERE image=?", $filename);
				$this->db->query($query);
				$count = $this->db->result('count');
				if($count == 0)
				{			
					$file = pathinfo($filename, PATHINFO_FILENAME);
					$ext = pathinfo($filename, PATHINFO_EXTENSION);
			
					$rezised_images = glob($this->config->root_dir.$this->config->resized_authors_images_dir.$file.".*x*.".$ext);
					if(is_array($rezised_images))
					foreach (glob($this->config->root_dir.$this->config->resized_authors_images_dir.$file.".*x*.".$ext) as $f)
						@unlink($f);
					@unlink($this->config->root_dir.$this->config->authors_images_dir.$filename);		
				}
			}	
		}
	}

	public function get_posts_authors($filter = array())
	{
		$post_id_filter = '';
		$author_id_filter = '';

		if(!empty($filter['post_id']))
			$post_id_filter = $this->db->placehold('AND post_id in(?@)', (array)$filter['post_id']);

		if(!empty($filter['author_id']))
			$author_id_filter = $this->db->placehold('AND author_id in(?@)', (array)$filter['author_id']);

		$query = $this->db->placehold("SELECT 
							post_id,
							author_id,
							position 
						FROM __posts_authors 
						WHERE 1
							$post_id_filter
							$author_id_filter
						ORDER BY position");
		$this->db->query($query);
		return $this->db->results();
	}

	public function get_post_authors($post_id = array())
	{
		if(empty($post_id))
			return array();

		$post_id_filter = $this->db->placehold('AND post_id in(?@)', (array)$post_id);
				
		$query = $this->db->placehold("SELECT post_id, author_id, position
					FROM __posts_authors
					WHERE 
					1
					$post_id_filter   
					ORDER BY position       
					");
		
		$this->db->query($query);
		return $this->db->results();
	}
	
	public function add_post_author($post_id, $author_id, $position=0)
	{
		$query = $this->db->placehold("INSERT IGNORE INTO __posts_authors SET post_id=?, author_id=?, position=?", $post_id, $author_id, $position);
		$this->db->query($query);
		return $author_id;
	}
	
	public function delete_post_author($post_id, $author_id)
	{
		$query = $this->db->placehold("DELETE FROM __posts_authors WHERE post_id=? AND author_id=? LIMIT 1", intval($post_id), intval($author_id));
		$this->db->query($query);
	}

	/*
	*
	* Функция возвращает пост по его id или url
	* (в зависимости от типа аргумента, int - id, string - url)
	* @param $id id или url поста
	*
	*/
	public function get_post($id)
	{
		if(is_int($id))
			$where = $this->db->placehold(' WHERE b.id=? ', intval($id));
		else
			$where = $this->db->placehold(' WHERE b.url=? ', $id);
		
		$query = $this->db->placehold("SELECT b.id,
											  b.type,
											  b.url, 
											  b.old_url,
											  b.name, 
											  b.annotation, 
											  b.text, 
											  b.meta_title,
		                               		  b.meta_keywords, 
		                               		  b.meta_description, 
		                               		  b.visible, 
		                               		  b.date,
		                               		  b.image, 
		                               		  b.rating, 
		                               		  b.votes,
											  b.date_modified
		                               FROM __blog b $where LIMIT 1");
		if($this->db->query($query))
			return $this->db->result();
		else
			return false; 
	}
	
	/*
	*
	* Функция возвращает массив постов, удовлетворяющих фильтру
	* @param $filter
	*
	*/
	public function get_posts($filter = array())
	{	
		// По умолчанию
		$limit = 1000;
		$page = 1;
		$post_id_filter = '';
		$type_filter = '';
		$visible_filter = '';
		$old_url_filter = '';
		$keyword_filter = '';
		$date_to_filter = '';
		$tag_id_filter = '';
		$author_id_filter = '';
		$is_featured_filter = '';
		$posts = array();
		
		if(isset($filter['limit']))
			$limit = max(1, intval($filter['limit']));

		if(isset($filter['page']))
			$page = max(1, intval($filter['page']));

		if(!empty($filter['type']))
			$type_filter = $this->db->placehold('AND b.type = ?', (int)$filter['type']);

		if(!empty($filter['id']))
			$post_id_filter = $this->db->placehold('AND b.id in(?@)', (array)$filter['id']);
			
		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND b.visible = ?', intval($filter['visible']));

		if(!empty($filter['old_url']))
			$old_url_filter = $this->db->placehold('AND b.old_url!=""');		
		
		if(isset($filter['keyword']))
		{
			$keywords = explode(' ', $filter['keyword']);
			foreach($keywords as $keyword)
				$keyword_filter .= $this->db->placehold('AND (b.name LIKE "%'.$this->db->escape(trim($keyword)).'%" OR b.meta_keywords LIKE "%'.$this->db->escape(trim($keyword)).'%") ');
		}

		if(!empty($filter['tag_id']))
		{
			$tag_id_filter = $this->db->placehold('INNER JOIN __posts_tags pt ON pt.post_id = b.id AND pt.tag_id in(?@)', (array)$filter['tag_id']);
			if(empty($group_by))
				$group_by = "GROUP BY b.id";
		}

		if(!empty($filter['author_id']))
		{
			$author_id_filter = $this->db->placehold('INNER JOIN __posts_authors pa ON pa.post_id = b.id AND pa.author_id in(?@)', (array)$filter['author_id']);
			if(empty($group_by))
				$group_by = "GROUP BY b.id";
		}

		if(isset($filter['date_to']))
			$date_to_filter = $this->db->placehold('AND b.date<=?', $filter['date_to']);

		if(isset($filter['featured']))
			$is_featured_filter = $this->db->placehold('AND b.featured=?', intval($filter['featured']));

		$sql_limit = $this->db->placehold(' LIMIT ?, ? ', ($page-1)*$limit, $limit);

		$query = $this->db->placehold("SELECT b.id, 
											  b.type, 
											  b.url, 
											  b.old_url,
											  b.name, 
											  b.annotation,
											  b.text,
		                                      b.meta_title, 
		                                      b.meta_keywords,
		                                      b.meta_description, 
		                                      b.visible,
		                                      b.date, 
		                                      b.image, 
		                                      b.featured,
		                                      b.rating, 
		                                      b.votes,
											  b.date_modified
		                                      FROM __blog b $tag_id_filter $author_id_filter WHERE 1 $type_filter $is_featured_filter $post_id_filter $visible_filter $date_to_filter $old_url_filter $keyword_filter 
		                                      ORDER BY date DESC, id DESC $sql_limit");
		
		$this->db->query($query);
		return $this->db->results();
	}
	
	
	/*
	*
	* Функция вычисляет количество постов, удовлетворяющих фильтру
	* @param $filter
	*
	*/
	public function count_posts($filter = array())
	{	
		$type_filter = '';
		$post_id_filter = '';
		$visible_filter = '';
		$keyword_filter = '';
		$tag_id_filter = '';
		$author_id_filter = '';
		$date_to_filter = '';
		
		

		if(!empty($filter['id']))
			$post_id_filter = $this->db->placehold('AND b.id in(?@)', (array)$filter['id']);
			
		if(!empty($filter['type']))
			$type_filter = $this->db->placehold('AND b.type = ?', (int)$filter['type']);

		if(isset($filter['visible']))
			$visible_filter = $this->db->placehold('AND b.visible = ?', intval($filter['visible']));		

		if(!empty($filter['tag_id']))
			$tag_id_filter = $this->db->placehold('INNER JOIN __posts_tags pt ON pt.post_id = b.id AND pt.tag_id in(?@)', (array)$filter['tag_id']);

		if(!empty($filter['author_id']))
			$author_id_filter = $this->db->placehold('INNER JOIN __posts_authors pa ON pa.post_id = b.id AND pa.author_id in(?@)', (array)$filter['author_id']);

		if(isset($filter['date_to']))
			$date_to_filter = $this->db->placehold('AND b.date<=?', $filter['date_to']);

		if(isset($filter['keyword']))
		{
			$keywords = explode(' ', $filter['keyword']);
			foreach($keywords as $keyword)
				$keyword_filter .= $this->db->placehold('AND (b.name LIKE "%'.$this->db->escape(trim($keyword)).'%" OR b.meta_keywords LIKE "%'.$this->db->escape(trim($keyword)).'%") ');
		}
		
		$query = "SELECT COUNT(distinct b.id) as count
		          FROM __blog b WHERE 1 $type_filter $post_id_filter $visible_filter $tag_id_filter $author_id_filter $date_to_filter $keyword_filter";

		if($this->db->query($query))
			return $this->db->result('count');
		else
			return false;
	}
	
	/*
	*
	* Создание поста
	* @param $post
	*
	*/	
	public function add_post($post)
	{	
		if(!isset($post->date))
			$date_query = ', date=NOW()';
		else
			$date_query = '';
		$query = $this->db->placehold("INSERT INTO __blog SET ?% $date_query", $post);
		
		if(!$this->db->query($query))
			return false;
		else
			return $this->db->insert_id();
	}
	
	
	/*
	*
	* Обновить пост(ы)
	* @param $post
	*
	*/	
	public function update_post($id, $post)
	{
		$query = $this->db->placehold("UPDATE __blog SET ?% WHERE id in(?@) LIMIT ?", $post, (array)$id, count((array)$id));
		$this->db->query($query);
		return $id;
	}


	/*
	*
	* Удалить пост
	* @param $id
	*
	*/	
	public function delete_post($id)
	{
		if(!empty($id))
		{
			$this->delete_image($id);
			
			$query = $this->db->placehold("DELETE FROM __blog WHERE id=? LIMIT 1", intval($id));
			if($this->db->query($query))
			{
				$query = $this->db->placehold("DELETE FROM __comments WHERE type='blog' AND object_id=?", intval($id));
				if($this->db->query($query))
					return true;
			}							
		}
		return false;
	}
	
	// Удалить изображение
	public function delete_image($post_ids)
	{
		$post_ids = (array) $post_ids;
		$query = $this->db->placehold("SELECT image FROM __blog WHERE id in(?@)", $post_ids);
		$this->db->query($query);
		$filenames = $this->db->results('image');
		if(!empty($filenames))
		{
			$query = $this->db->placehold("UPDATE __blog SET image=NULL WHERE id in(?@)", $post_ids);
			$this->db->query($query);
			foreach($filenames as $filename)
			{
				$query = $this->db->placehold("SELECT count(*) as count FROM __blog WHERE image=?", $filename);
				$this->db->query($query);
				$count = $this->db->result('count');
				if($count == 0){
					$file = pathinfo($filename, PATHINFO_FILENAME);
					$ext = pathinfo($filename, PATHINFO_EXTENSION);
			
					// Удалить все ресайзы
					$rezised_images = glob($this->config->root_dir.$this->config->resized_blog_images_dir.$file."*.".$ext);
					if(is_array($rezised_images))
						foreach (glob($this->config->root_dir.$this->config->resized_blog_images_dir.$file."*.".$ext) as $f)
							@unlink($f);

					@unlink($this->config->root_dir.$this->config->blog_images_dir.$filename);	
				}
			}	
		}
	}	
	

	/*
	*
	* Следующий пост
	* @param $post
	*
	*/	
	public function get_next_post($id, $type)
	{


		$this->db->query("SELECT date FROM __blog WHERE id=? LIMIT 1", $id);
		$date = $this->db->result('date');

		$this->db->query("(SELECT id FROM __blog WHERE date=? AND id>? AND type=? AND visible  ORDER BY id limit 1)
		                   UNION
		                  (SELECT id FROM __blog WHERE date>? AND date<=? AND visible AND type=? ORDER BY date, id limit 1)",
		                  $date, $id, $type, $date, date('Y-m-d H:i:s'), $type);
		$next_id = $this->db->result('id');
		if($next_id)
			return $this->get_post(intval($next_id));
		else
			return false; 
	}
	
	/*
	*
	* Предыдущий пост
	* @param $post
	*
	*/	
	public function get_prev_post($id, $type)
	{
		$this->db->query("SELECT date FROM __blog WHERE id=? LIMIT 1", $id);
		$date = $this->db->result('date');

		$this->db->query("(SELECT id FROM __blog WHERE date=? AND id<? AND type=? AND visible ORDER BY id DESC limit 1)
		                   UNION
		                  (SELECT id FROM __blog WHERE date<? AND visible AND type=? ORDER BY date DESC, id DESC limit 1)",
		                  $date, $id, $type, $date, $type);
		$prev_id = $this->db->result('id');
		if($prev_id)
			return $this->get_post(intval($prev_id));
		else
			return false; 
	}
}
