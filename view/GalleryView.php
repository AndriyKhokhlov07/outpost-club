<?PHP

require_once('View.php');

class GalleryView extends View
{
	function fetch()
	{
		
		// Галерея
		$url = $this->request->get('gallery', 'string');
		$gallery = $this->galleries->get_gallery($url);
		
		if(empty($gallery) || $gallery->visible==0)
		{
			return false;
		}
		else
		{
			// Категория
			$gallery_categories = $this->galleries->get_gallery_categories((int)$gallery->id);
			$gallery_category = current($gallery_categories);
			$category = $this->galleries->get_category_i((int)$gallery_category->category_id);
			
			$images = array();
			foreach($this->galleries->get_images(array('gallery_id'=>$gallery->id)) as $i)
				$images[$i->id] = $i;
			
			if(!empty($images))
			{
				// Выбераем связанные товары и услуги	
				$related = $this->galleries->get_related(array('image_id'=>array_keys($images)));
				$related_products = array();
				$related_services = array();
				foreach($related as $r)
				{
					if($r->type == 1)
						$related_products[$r->related_id] = $r->related_id;
					elseif($r->type == 2)
						$related_services[$r->related_id] = $r->related_id;
				}
				if(!empty($related_products))
				{
					/*foreach($related_products as &$r_p)
						$r_products[$r_p->related_id] = &$r_p;*/
						
					$temp_products = $this->products->get_products(array('id'=>$related_products));
					foreach($temp_products as $temp_product)
						$related_products[$temp_product->id] = $temp_product;
					$related_products_images = $this->products->get_images(array('product_id'=>array_keys($related_products)));
					foreach($related_products_images as $i)
						$related_products[$i->product_id]->images[] = $i;
					foreach($related_products as $rp)
						$related_products[$rp->id]->image = $rp->images[0];
				}
				// Связанные услуги
				if(!empty($related_services))
				{
					foreach($this->pages->get_pages(array('id'=>$related_services, 'visible'=>1)) as $rs)
						$related_services[$rs->id] = $rs;
				}
				
				// Распределяем связанные по картинкам
				foreach($related as $r)
				{
					if($r->type == 1 && !empty($related_products[$r->related_id]))
						$images[$r->image_id]->related_products[] = $related_products[$r->related_id];
					elseif($r->type == 2  && !empty($related_services[$r->related_id]))
						$images[$r->image_id]->related_services[] = $related_services[$r->related_id];
				}
			}
			
		}
		
		$this->design->assign('gallery_category', $category);
		$this->design->assign('gallery', $gallery);
		$this->design->assign('images', $images);
		$this->design->assign('meta_title', $gallery->meta_title);
		$this->design->assign('meta_keywords', $gallery->meta_keywords);
		$this->design->assign('meta_description', $gallery->meta_description);
			
		return $this->design->fetch('gallery.tpl');
	}
}