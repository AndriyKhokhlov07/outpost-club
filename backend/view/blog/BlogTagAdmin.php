<?php

require_once('api/Backend.php');


class BlogTagAdmin extends Backend
{
  private $allowed_image_extentions = array('png', 'gif', 'jpg', 'jpeg', 'ico');
  
  function fetch()
  {
		$tag = new stdClass;
		$images = array();
		$related_posts = array(); 
		if($this->request->method('post'))
		{
			
			$tag->id 					= $this->request->post('id', 'integer');
			$tag->visible 				= $this->request->post('visible', 'boolean');
			$tag->url					= $this->request->post('url', 'string');
			$tag->meta_title 	   		= $this->request->post('meta_title');
			$tag->meta_description 		= $this->request->post('meta_description');
			$tag->name 			  		= $this->request->post('name');
			$tag->description 	   		= $this->request->post('description');
			
			
			if($this->request->post('related_posts'))
			{
				foreach($this->request->post('related_posts') as $rp)
				{
					if(!empty($rp))
						$related_posts[] = $rp;
				}
			}
			$tag->related_posts = serialize($related_posts);
			
	
			// Не допустить одинаковые URL разделов.
			if(($c = $this->blog->get_tag($tag->url)) && $c->id!=$tag->id)
			{	
				$this->design->assign('message_error', 'url_exists');
			}
			else
			{
				if(empty($tag->id))
				{
	  				$tag->id   = $this->blog->add_tag($tag);
					$this->design->assign('message_success', 'added');

	  			}
  	    		else
  	    		{
  	    			$this->blog->update_tag($tag->id, $tag);
					$this->design->assign('message_success', 'updated');
  	    		}
				
				
  	    		// Удаление изображения
  	    		if($this->request->post('delete_image'))
  	    		{
  	    			$this->blog->delete_tag_image($tag->id);
  	    		}
  	    		// Загрузка изображения
  	    		$image = $this->request->files('image');
  	    		if(!empty($image['name']) && in_array(strtolower(pathinfo($image['name'], PATHINFO_EXTENSION)), $this->allowed_image_extentions))
  	    		{
  	    			$this->blog->delete_tag_image($tag->id);
  	    			move_uploaded_file($image['tmp_name'], $this->root_dir.$this->config->blog_tags_images_dir.$image['name']);
  	    			$this->blog->update_tag($tag->id, array('image'=>$image['name']));
  	    		}

				$tag = $this->blog->get_tag(intval($tag->id));
			}
		}
		else
		{
			$tag->id = $this->request->get('id', 'integer');
			
			$tag = $this->blog->get_tag($tag->id);

			if(empty($tag))
				$tag = new stdClass;
			
			
		}
		

		if(!empty($tag->related_posts))
		{
			$related_posts_ = unserialize($tag->related_posts);
			if(!empty($related_posts_))
			{
				foreach($related_posts_ as $rp)
					$related_posts[$rp] = $rp;

				$related_posts_items = $this->blog->get_posts(array('id'=>$related_posts));
				if(!empty($related_posts_items))
				{
					foreach($related_posts_items as $rp)
						$related_posts[$rp->id] = $rp;
					foreach($related_posts as $id=>$rp)
					{
						if(!is_object($related_posts[$id]))
							unset($related_posts[$id]);
					}

					unset($related_posts_items, $related_posts_ids);
					$tag->related_posts = $related_posts;
				}
			}
			else
				unset($tag->related_posts);
		}

		$this->design->assign('tag', $tag);
		return  $this->design->fetch('blog/tag.tpl');
	}
}