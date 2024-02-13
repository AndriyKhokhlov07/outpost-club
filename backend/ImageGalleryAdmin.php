<?PHP 

require_once('api/Backend.php');


########################################
class ImageGalleryAdmin extends Backend
{

  function fetch()
  {
	  	$image = new stdClass;
		$image->gallery_id = $this->request->get('gallery_id');
		
		$related_products = array();
		$related_services = array();
		
		if($this->request->method('POST'))
		{
			$image->id = $this->request->post('id', 'integer');
			$image->name = $this->request->post('name');
			$image->annotation = $this->request->post('annotation');
			//$image->gallery_id = $this->request->post('gallery_id', 'integer');
			
			if(empty($image->id))
			{
	  			$image->id = $this->galleries->add_image($image);
				$this->design->assign('message_success', 'added');
	  		}
  	    	else
  	    	{
  	    		$this->galleries->update_image($image->id, $image);
				$this->design->assign('message_success', 'updated');
  	    	}
			if(!empty($image->id))	
			{
				// Удаление изображения
				if($this->request->post('delete_image'))
					$this->galleries->delete_image_file($image->id);

				// Загрузка изображения
				$image_file = $this->request->files('image');
				if($image_name = $this->image->upload_image($image_file['tmp_name'], $image_file['name'], 'gallery'))
				{
					$this->galleries->update_image($image->id, array('filename'=>$image_name));
					$image->filename = $image_name;
				}
				else
					$this->design->assign('error', 'error uploading image');
					
				// Удаление связанных товаров и услуг
				$this->galleries->delete_related(array('image_id'=>$image->id));
					
				// Связанные товары
				if(is_array($this->request->post('related_products')))
				{
					foreach($this->request->post('related_products') as $p)
					{
						$rp[$p] = new stdClass;
						//$rp[$p]->product_id = $product->id;
						$rp[$p]->related_id = $p;
					}
					$related_products = $rp;
				}
				if(is_array($related_products))
				{
					$pos = 0;
		  		    foreach($related_products  as $i=>$related_product)
	   	    			$this->galleries->add_related($image->id, $related_product->related_id, 'products', $pos++);
				}
				
				// Связанные услуги
				if(is_array($this->request->post('related_services')))
				{
					foreach($this->request->post('related_services') as $s)
					{
						$rs[$s] = new stdClass;
						$rs[$s]->related_id = $s;
					}
					$related_services = $rs;
				}
				
				if(is_array($related_services))
				{
					$pos = 0;
		  		    foreach($related_services  as $i=>$related_service)
	   	    			$this->galleries->add_related($image->id, $related_service->related_id, 'services', $pos++);
				}
				
			}
		}
		else
		{
			$image->id = $this->request->get('id', 'integer');
		}
		
		
		
		if(!empty($image->id)){
			
			$image = $this->galleries->get_image($image->id);
					
			// Связанные товары и услуги
			$related_products = array();
			$related_services = array();
			foreach($this->galleries->get_related(array('image_id'=>$image->id)) as $related)
			{
				if($related->type == 1)		// products
					$related_products[] = $related;
				elseif($related->type == 2) // services
					$related_services[] = $related;
			}
			
			// Связанные товары
			if(!empty($related_products))
			{
				foreach($related_products as &$r_p)
					$r_products[$r_p->related_id] = &$r_p;
				$temp_products = $this->products->get_products(array('id'=>array_keys($r_products)));
				foreach($temp_products as $temp_product)
					$r_products[$temp_product->id] = $temp_product;
				$related_products_images = $this->products->get_images(array('product_id'=>array_keys($r_products)));
				foreach($related_products_images as $i)
					$r_products[$i->product_id]->images[] = $i;
			}
		
			// Связанные услуги
			if(!empty($related_services))
			{
				foreach($related_services as &$r_s)
					$r_services[$r_s->related_id] = &$r_s;
				$temp_services = $this->pages->get_pages(array('id'=>array_keys($r_services), 'visible'=>1));
				foreach($temp_services as $temp_service)
					$r_services[$temp_service->id] = $temp_service;
			}
		}
		
		
		if(!empty($image->gallery_id))
			$gallery = $this->galleries->get_gallery(intval($image->gallery_id));
		
		$this->design->assign('related_products', $related_products);
		$this->design->assign('related_services', $related_services);
		
		
		$this->design->assign('gallery', $gallery);
 		$this->design->assign('image', $image);
		return  $this->design->fetch('gallery_image.tpl');
	}
}