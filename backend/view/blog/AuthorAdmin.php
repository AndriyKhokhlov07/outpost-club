<?php

require_once('api/Backend.php');


class AuthorAdmin extends Backend
{
  private $allowed_image_extentions = array('png', 'gif', 'jpg', 'jpeg', 'ico');
  
  function fetch()
  {
		$author = new stdClass;
		$images = array();

		if($this->request->method('post'))
		{
			$author->id 				   = $this->request->post('id', 'integer');
			$author->url				   = $this->request->post('url', 'string');
			$author->visible 			   = $this->request->post('visible', 'boolean');
			$author->name 	   = $this->request->post('name');
			$author->post 	   = $this->request->post('post');
			$author->text = $this->request->post('text');
			
			if(!empty($author->id) && $this->request->post('action') == 'delete')
			{
				$this->blog->delete_author($author->id);
				header('location: '.$this->config->root_url.'/backend/index.php?module=AuthorsAdmin');
			}
			
			// Не допустить одинаковые URL
			if(($a = $this->blog->get_author($author->url)) && $a->id!=$author->id)
			{	
				$this->design->assign('message_error', 'url_exists');
			}
			else
			{
				if(empty($author->id))
				{
					unset($author->id);
		  			$author->id = $this->blog->add_author($author);
					$this->design->assign('message_success', 'added');
		  		}
	  	    	else
	  	    	{
  	   				$this->blog->update_author($author->id, $author);
					$this->design->assign('message_success', 'updated');
	  	   		}

	  	    	if($author->id)
	  	    	{

		  	    	// Удаление изображения
		  	    	if($this->request->post('delete_image'))
		  	    	{
		  	    		$this->blog->delete_author_image($author->id);
		  	   		}
		  	    	// Загрузка изображения
		  	    	$image = $this->request->files('image');
		  	   		if(!empty($image['name']) && in_array(strtolower(pathinfo($image['name'], PATHINFO_EXTENSION)), $this->allowed_image_extentions))
		  	    	{
		  	    		$this->blog->delete_author_image($author->id);
		  	   			move_uploaded_file($image['tmp_name'], $this->root_dir.$this->config->authors_images_dir.$image['name']);
		  	   			$this->blog->update_author($author->id, array('image'=>$image['name']));
		  	   		}

					$author = $this->blog->get_author(intval($author->id));
				}
			}
			
		}
		else
		{
			$author->id = $this->request->get('id', 'integer');
			$author = $this->blog->get_author($author->id);
			if(empty($author))
				$author = new stdClass;

		}
		

		$this->design->assign('author', $author);
		return  $this->design->fetch('blog/author.tpl');
	}
}