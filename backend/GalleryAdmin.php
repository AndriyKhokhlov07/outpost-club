<?PHP
require_once('api/Backend.php');

class GalleryAdmin extends Backend
{	
	public function fetch()
	{	
		$gallery = new stdClass;
		$gallery_categories = array();
		
		if($this->request->method('POST'))
		{
			$gallery->id = $this->request->post('id', 'integer');
			$gallery->name = $this->request->post('name');
			$gallery->url = $this->request->post('url');
			$gallery->meta_title = $this->request->post('meta_title');
			$gallery->meta_keywords = $this->request->post('meta_keywords');
			$gallery->meta_description = $this->request->post('meta_description');
			$gallery->annotation = $this->request->post('annotation');
			$gallery->body = $this->request->post('body');
			$gallery->visible = $this->request->post('visible', 'boolean');
			
			
			// Сортировка
			$positions = $this->request->post('positions'); 		
			$ids = array_keys($positions);
			sort($positions);
			foreach($positions as $i=>$position)
				$this->galleries->update_image($ids[$i], array('position'=>$position));
			
			
			// Действия с выбранными
			$ids = $this->request->post('check');
			//print_r($ids); exit;
			if(is_array($ids))
			switch($this->request->post('action'))
			{
				case 'delete':
		    {
			    foreach($ids as $id)
					$this->galleries->delete_image($id);    
		        break;
		    }
			}
			
			// Категории галереи
			$gallery_categories = $this->request->post('categories');
				
			## Не допустить одинаковые URL разделов.
			if(($g = $this->galleries->get_gallery($gallery->url)) && $g->id!=$gallery->id)
			{			
				$this->design->assign('message_error', 'url_exists');
			}
			else
			{
				if(empty($gallery->id))
				{
	  				$gallery->id = $this->galleries->add_gallery($gallery);
	  				$gallery = $this->galleries->get_gallery($gallery->id);
	  				$this->design->assign('message_success', 'added');
  	    		}
  	    		else
  	    		{
  	    			$this->galleries->update_gallery($gallery->id, $gallery);
	  				$gallery = $this->galleries->get_gallery($gallery->id);
	  				$this->design->assign('message_success', 'updated');
   	    		}
			}
			if(!empty($gallery->id))
				$this->galleries->update_gallery_categories($gallery->id, $gallery_categories);
		}
		else
		{
			$id = $this->request->get('id', 'integer');
			if(!empty($id))
				$gallery = $this->galleries->get_gallery(intval($id));			
			else
				$gallery->visible = 1;
		}
		
		
		// Изображения
		if(!empty($gallery->id))
			$images = $this->galleries->get_images(array('gallery_id'=>$gallery->id));

		// Категории
		$categories = $this->galleries->get_categories_tree();
 		$this->design->assign('categories', $categories);
		
		// Категории галереи
		$gallery_categories = array();	
		if(!empty($gallery->id))
			$gallery_categories = $this->galleries->get_gallery_categories($gallery->id);
		if(empty($gallery_categories))
		{
			if($category_id = $this->request->get('category_id'))
				$gallery_categories[0]->category_id = $category_id;		
			else
				$gallery_categories = array(1);
		}
		
		$this->design->assign('images', $images);
		$this->design->assign('gallery_categories', $gallery_categories);
		$this->design->assign('gallery', $gallery);

 	  	return $this->design->fetch('gallery.tpl');
	}
	
}

