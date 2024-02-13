<?PHP

require_once('api/Backend.php');

class PostAdmin extends Backend
{
	
	private	$allowed_image_extentions = array('png', 'gif', 'jpg', 'jpeg', 'ico');
	
	public function fetch()
	{
		$type = $this->request->get('type', 'integer');
		$post = new stdClass;
		$post_tags = array();
		$post_authors = array();

		if($this->request->method('post'))
		{
			$post->id = $this->request->post('id', 'integer');
			$post->name = $this->request->post('name');
			$post->type = $this->request->post('type', 'integer');
			$post->date = date('Y-m-d', strtotime($this->request->post('date')));
			if (empty($this->request->post('date_modified'))) {
				$post->date_modified = null;
			}
			else {
				$post->date_modified = date('Y-m-d H:i:s', strtotime($this->request->post('date_modified')));
			}
			
			
			
			$post->visible = $this->request->post('visible', 'boolean');

			$post->url = $this->request->post('url', 'string');
			$post->old_url = $this->request->post('old_url');
			$post->meta_title = $this->request->post('meta_title');
			$post->meta_keywords = $this->request->post('meta_keywords');
			$post->meta_description = $this->request->post('meta_description');
			
			$post->annotation = $this->request->post('annotation');
			$post->text = $this->request->post('body');



			// Теги записи
			$post_tags_ = $this->request->post('tags');
			if(is_array($post_tags_))
			{
				foreach($post_tags_ as $t)
				{
					if($t != 0)
					{
						$x = new stdClass;
						$x->id = $t;
						$pt[] = $x;
					}
				}
				if(!empty($pt))
					$post_tags = $pt;
			}
			

 			// Не допустить одинаковые URL разделов.
			if(($a = $this->blog->get_post($post->url)) && $a->id!=$post->id)
			{			
				$this->design->assign('message_error', 'url_exists');
			}
			else
			{
				$blog_date_modified_update = false;
				if(empty($post->id))
				{
	  				$post->id = $this->blog->add_post($post);
	  				$post = $this->blog->get_post($post->id);
					$this->design->assign('message_success', 'added');
					$blog_date_modified_update = true;
	  			}
  	    		else
  	    		{
					$post_before_update = $this->blog->get_post($post->id);
					if ($post_before_update->text != $post->text || $post_before_update->name != $post->name || $post_before_update->annotation != $post->annotation) {
						$post->date_modified = date('Y-m-d H:i:s');
					}
  	    			$this->blog->update_post($post->id, $post);
  	    			$post = $this->blog->get_post($post->id);
					$this->design->assign('message_success', 'updated');
					$blog_date_modified_update = true;
  	    		}
				
				// Update date modified on Blog-page
				if ($blog_date_modified_update) {
					$blog_page_upd = [
						'date_modified' => date('Y-m-d H:i:s')
					];
					$query = $this->db->placehold('UPDATE __pages SET ?% WHERE url in (?@) LIMIT 2', $blog_page_upd, ['blog', '']);
					$this->db->query($query);
				}

  	    		// Теги записи
   	    		$query = $this->db->placehold('DELETE FROM __posts_tags WHERE post_id=?', $post->id);
   	    		$this->db->query($query);
 	  		    if(is_array($post_tags))
	  		    {
	  		    	foreach($post_tags as $i=>$tag)
   	    				$this->blog->add_post_tag($post->id, $tag->id, $i);
  	    		}

				// Удаление изображения
  	    		if($this->request->post('delete_image')){
  	    			$this->blog->delete_image($post->id);
					unset($post->image);
  	    		}
  	    		// Загрузка изображения
  	    		$image = $this->request->files('image');
  	    		if(!empty($image['name']) && in_array(strtolower(pathinfo($image['name'], PATHINFO_EXTENSION)), $this->allowed_image_extentions))
  	    		{
  	    			$this->blog->delete_image($post->id);
					
					$uploaded_file = $new_name = pathinfo($image['name'], PATHINFO_BASENAME);
					$base = pathinfo($uploaded_file, PATHINFO_FILENAME);
					$ext = pathinfo($uploaded_file, PATHINFO_EXTENSION);
					
					while(file_exists($this->config->root_dir.$this->config->blog_images_dir.$new_name)){	
						$new_base = pathinfo($new_name, PATHINFO_FILENAME);
						if(preg_match('/_([0-9]+)$/', $new_base, $parts))
							$new_name = $base.'_'.($parts[1]+1).'.'.$ext;
						else
							$new_name = $base.'_1.'.$ext;
					}
					if(move_uploaded_file($image['tmp_name'], $this->config->root_dir.$this->config->blog_images_dir.$new_name)){
						$this->blog->update_post($post->id, array('image'=>$new_name));
						$post->image = $new_name;
					}		
  	    		}
  	    		// Авторы
				if(is_array($this->request->post('post_authors')))
				{
					foreach($this->request->post('post_authors') as $a)
					{
						$pa[$a] = new stdClass;
						$pa[$a]->post_id = $post->id;
						$pa[$a]->author_id = $a;
					}
					$post_authors = $pa;
				}
	   	    	$query = $this->db->placehold('DELETE FROM __posts_authors WHERE post_id=?', $post->id);
	   	    	$this->db->query($query);
	 	  	    if(!empty($post_authors))
		  		{
		  	    	$pos = 0;
		  		   	foreach($post_authors  as $i=>$post_author)
	   	    			$this->blog->add_post_author($post->id, $post_author->author_id, $pos++);
	  	    	}

	  	    	$post = $this->blog->get_post(intval($post->id));
				
			}	
		}
		else
		{
			$post->id = $this->request->get('id', 'integer');
			$post = $this->blog->get_post(intval($post->id));
		}

		if(empty($post))
		{
			$post = new stdClass;
			$post->date = date($this->settings->date_format, time());
		}
 		
		if(!empty($post->id))
		{
			// Теги записи
			$post_tags = $this->blog->get_posts_tags(array('post_id'=>$post->id));

			// Авторы
			$post_authors = $this->blog->get_authors(array('post_id'=>$post->id));
			if(!empty($post_authors))
				$this->design->assign('post_authors', $post_authors);

			// Tags
			if(empty($post_tags))
			{
				if($tag_id = $this->request->get('tag_id'))
					$post_tags[0]->id = $tag_id;		
				else
					$post_tags = array(1);
			}
			$this->design->assign('post_tags', $post_tags);
			$this->design->assign('tags', $this->blog->get_tags());
		}

		$this->design->assign('post', $post);
		
		if(!empty($post->type))
			$type = $post->type;
		$this->design->assign('type', $type);
		
		
 	  	return $this->design->fetch('post.tpl');
	}
}