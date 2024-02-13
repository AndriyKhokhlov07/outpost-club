<?php

require_once('api/Backend.php');

class CategoryGalleriesAdmin extends Backend
{
  
  function fetch()
  {
		$category = new stdClass;
		if($this->request->method('post'))
		{
			$category->id = $this->request->post('id', 'integer');
			$category->parent_id = $this->request->post('parent_id', 'integer');
			$category->name = $this->request->post('name');
			$category->visible = $this->request->post('visible', 'boolean');

			$category->url = $this->request->post('url', 'string');
			$category->meta_title = $this->request->post('meta_title');
			$category->meta_keywords = $this->request->post('meta_keywords');
			$category->meta_description = $this->request->post('meta_description');
			
			$category->description = $this->request->post('description');
	
			// Не допустить одинаковые URL разделов.
			if(($c = $this->galleries->get_category($category->url)) && $c->id!=$category->id)
			{			
				$this->design->assign('message_error', 'url_exists');
			}
			else
			{
				if(empty($category->id))
				{
	  				$category->id = $this->galleries->add_category($category);
					$this->design->assign('message_success', 'added');
	  			}
  	    		else
  	    		{
  	    			$this->galleries->update_category($category->id, $category);
					$this->design->assign('message_success', 'updated');
  	    		}
  	    		$category = $this->galleries->get_category(intval($category->id));
			}
		}
		else
		{
			$category->id = $this->request->get('id', 'integer');
			$category = $this->galleries->get_category($category->id);
		}
		

		$categories = $this->galleries->get_categories_tree();

		$this->design->assign('category', $category);
		$this->design->assign('categories', $categories);
		return  $this->design->fetch('gallery_category.tpl');
	}
}