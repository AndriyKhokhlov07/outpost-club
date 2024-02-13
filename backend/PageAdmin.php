<?PHP
require_once('api/Backend.php');

class PageAdmin extends Backend
{	
	private $allowed_image_extentions = array('png', 'gif', 'jpg', 'jpeg', 'ico');
	
	public function fetch()
	{	
		$block_images = array();
		$blocks = array();

		// Администратор
	  	$manager = $this->managers->get_manager();
	  	if(!empty($manager->permissions))
		{
			$menu_permissions = array();
			foreach($manager->permissions as $permission)
			{
				$p_arr = explode('_', $permission);
				if(count($p_arr) == 2 && $p_arr[0] == 'menu')
				{
					$menu_permissions[] = (int)$p_arr[1];
				}
			}
		}

		$page = new stdClass;
		if($this->request->method('POST'))
		{	


			$page->id = $this->request->post('id', 'integer');
			$page->parent_id = $this->request->post('parent_id', 'integer');
			$page->nebo_id = $this->request->post('nebo_id', 'integer');
			$page->name = $this->request->post('name');
			$page->header = $this->request->post('header');
			$page->url = $this->request->post('url');
			$page->old_url = $this->request->post('old_url');
			$page->meta_title = $this->request->post('meta_title');
			$page->meta_keywords = $this->request->post('meta_keywords');
			$page->meta_description = $this->request->post('meta_description');
			$page->body = $this->request->post('body');
            $page->body2 = $this->request->post('body2');
			if($this->request->post('move_in'))
				$page->move_in = $this->request->post('move_in');
			$page->menu_id = $this->request->post('menu_id', 'integer');
			$page->service_ids = $this->request->post('services');
			$page->visible = $this->request->post('visible', 'boolean');
			$page->new = $this->request->post('new', 'integer');
			$page->coming_soon = $this->request->post('coming_soon', 'integer');
			$page->featured = $this->request->post('featured', 'integer');

			if (empty($this->request->post('date_modified'))) {
				$page->date_modified = null;
			} 
			else {
				$page->date_modified = date('Y-m-d H:i:s', strtotime($this->request->post('date_modified')));
			}


			$page->applicaation_page_id = $this->request->post('applicaation_page_id', 'integer');
			if(empty($page->applicaation_page_id))
				$page->applicaation_page_id = 0;
			$page->apply_name = $this->request->post('apply_name');
			if(empty($page->apply_name))
				$page->apply_name = '';


			if($this->request->post('neighborhood'))
				$page->neighborhood = $this->request->post('neighborhood');

            if($this->request->post('neighborhood_id'))
                $page->neighborhood_id = $this->request->post('neighborhood_id', 'integer');

			if($this->request->post('latitude'))
				$page->latitude = $this->request->post('latitude');
			if($this->request->post('longitude'))
				$page->longitude = $this->request->post('longitude');

			$page->icon = $this->request->post('icon');
			if($this->request->post('annotation'))
				$page->annotation = $this->request->post('annotation');
			if($this->request->post('bg_text'))
				$page->bg_text = $this->request->post('bg_text');
			

			$old_images = array();

			if(!empty($page->id))
			{
				$old_page = $this->pages->get_page(intval($page->id));
				if(!empty($old_page))
				{
					if(!in_array($old_page->menu_id, $menu_permissions))
					{
						return 'Permission denied';
					}
					
					$page_blocks = unserialize($old_page->blocks);
					if(!empty($page_blocks))
					{
						foreach ($page_blocks as $pb) 
						{
							if(!empty($pb->images))
							{
								foreach ($pb->images as $img_name) 
								{
									$old_images[$img_name] = $img_name;
								}								
							}
						}
					}
				}
			}


			// BLOCKS
			if($this->request->post('blocks'))
			foreach($this->request->post('blocks') as $n=>$bl)
			{
				foreach($bl as $i=>$b)
				{
					if(empty($blocks[$i]))
						$blocks[$i] = new stdClass;
					$blocks[$i]->$n = $b;
					if($n == "images")
					{
						foreach($b as $img)
						{
							if(isset($old_images[$img]))
								unset($old_images[$img]);
						}
					}
				}
			}
			if(!empty($old_images))
			{
				foreach($old_images as $i)
				{
					$file = pathinfo($i, PATHINFO_FILENAME);
					$ext = pathinfo($i, PATHINFO_EXTENSION);
					
					// Удалить все ресайзы
					$rezised_images = glob($this->config->root_dir.$this->resized_galleries_images_dir.$file.".*x*.".$ext);
					if(is_array($rezised_images))
					{
						foreach (glob($this->config->root_dir.$this->config->resized_galleries_images_dir.$file.".*x*.".$ext) as $f)
							@unlink($f);
					}
					@unlink($this->config->root_dir.$this->config->galleries_images_dir.$i);	
				}
			}

			$block_key = 'first';
			$block_images = $this->request->files('blocks_images');
			if(!empty($block_images))
			{
				foreach ($block_images['name'] as $k=>$images)
				{
					for($i=0; $i<count($images); $i++)
					{
						if ($image_name = $this->image->upload_image($block_images['tmp_name'][$k][$i], $block_images['name'][$k][$i]))
						{
							$blocks[$k]->images[] = $image_name;
						}
					}
				}
			}

			$page->blocks = serialize($blocks);


			if($this->request->post('b'))
			{
				$page->blocks = serialize($this->request->post('b'));
			}

            $page->blocks2 = '';
            if ($faq = $this->request->post('faq')) {
                if (!empty($faq)) {
                    $page->blocks2 = serialize($faq);
                }
                unset($faq);
            }



			$page->related = '';
			if($this->request->post('related'))
			{
				$page_related = array();
				foreach($this->request->post('related') as $r)
				{
					if(!empty($r))
						$page_related[] = $r;
				}
				$page->related = serialize($page_related);
			}

			$page->related_houses = '';
			if($this->request->post('related_houses'))
			{
				$page_related = array();
				foreach($this->request->post('related_houses') as $r)
				{
					if(!empty($r))
						$page_related[] = $r;
				}
				$page->related_houses = serialize($page_related);
			}



			if(!empty($page->service_ids))
				$page->service_ids = serialize($page->service_ids);
			else
				$page->service_ids = '';
	
			## Не допустить одинаковые URL разделов.
			if(($p = $this->pages->get_page($page->url)) && $p->id!=$page->id)
			{			
				$this->design->assign('message_error', 'url_exists');
			}
			else
			{
				if(empty($page->id))
				{
	  				$page->id = $this->pages->add_page($page);
	  				$page = $this->pages->get_page($page->id);
	  				$this->design->assign('message_success', 'added');
  	    		}
  	    		else
  	    		{
					$page_before_update = $this->pages->get_page($page->id);
					if ($page_before_update->date_modified == $page->date_modified) {
						$page->date_modified = date('Y-m-d H:i:s');
					}

  	    			$this->pages->update_page($page->id, $page);
	  				$page = $this->pages->get_page($page->id);
	  				$this->design->assign('message_success', 'updated');
   	    		}

				// If update House-page update date modified on Home-page 
				// 5 - Houses
				if ($page->menu_id == 5) {
					$home_page_upd = [
						'date_modified' => date('Y-m-d H:i:s')
					];
					$query = $this->db->placehold('UPDATE __pages SET ?% WHERE url in (?@) LIMIT 2', $home_page_upd, ['']);
					$this->db->query($query);
				}


				// Удаление изображения
  	    		if($this->request->post('delete_image')){
  	    			$this->pages->delete_image($page->id);
					if(!empty($page->image))
						unset($page->image);
  	    		}
  	    		// Загрузка изображения
  	    		$image = $this->request->files('image');
  	    		if(!empty($image['name']) && in_array(strtolower(pathinfo($image['name'], PATHINFO_EXTENSION)), $this->allowed_image_extentions)){
  	    			$this->pages->delete_image($page->id);	    			
  	    			move_uploaded_file($image['tmp_name'], $this->root_dir.$this->config->pages_images_dir.$image['name']);
  	    			$this->pages->update_page($page->id, array('image'=>$image['name']));
					$page->image = $image['name'];
  	    		}

  	    		// Удаление изображения бекграунда
  	    		if($this->request->post('delete_bg_image')){
  	    			$this->pages->delete_bg_image($page->id);
					if(!empty($page->bg_image))
						unset($page->bg_image);
  	    		}
  	    		// Загрузка изображения бекграунда
  	    		$bg_image = $this->request->files('bg_image');
  	    		if(!empty($bg_image['name']) && in_array(strtolower(pathinfo($bg_image['name'], PATHINFO_EXTENSION)), $this->allowed_image_extentions)){
  	    			$this->pages->delete_bg_image($page->id);	    			
  	    			move_uploaded_file($bg_image['tmp_name'], $this->root_dir.$this->config->pages_bg_images_dir.$bg_image['name']);
  	    			$this->pages->update_page($page->id, array('bg_image'=>$bg_image['name']));
					$page->bg_image = $bg_image['name'];
  	    		}
			}
		}
		else
		{
			$id = $this->request->get('id', 'integer');
			if(!empty($id))
			{
				$page = $this->pages->get_page(intval($id));	
				if(!empty($page))
				{
					if(!in_array($page->menu_id, $menu_permissions))
					{
						return 'Permission denied';
					}
				}		
			}
			else
			{
				$page->menu_id = $this->request->get('menu_id');
				$page->visible = 1;
			}
		}	

		if(!empty($page->service_ids))
			$page->service_ids = unserialize($page->service_ids);

		if(!empty($page->blocks))
			$page->blocks = unserialize($page->blocks);

		//print_r($page->blocks); exit;

		// Related pages (Services)
		if(!empty($page->related)){
			$page->related = unserialize($page->related);
		}
		if(!empty($page->related))
		{
			$related_pages = array();
			$r_pages = $this->blog->get_posts(array('id'=>$page->related));
			if(!empty($r_pages))
			{
				foreach($r_pages as $p)
					$related_pages[$p->id] = $p;
			}
			$page->related = $related_pages;
		}

		// Related pages (Houses)
		if(!empty($page->related_houses)){
			$page->related_houses = unserialize($page->related_houses);
		}
		if(!empty($page->related_houses))
		{
			$related_pages = array();
			$r_pages = $this->pages->get_pages(array('id'=>$page->related_houses));
			if(!empty($r_pages))
			{
				foreach($r_pages as $p)
					$related_pages[$p->id] = $p;
			}
			$page->related_houses = $related_pages;
		}

        // FAQ
        if (!empty($page->blocks2)) {
            $page->blocks2 = unserialize($page->blocks2);
        } else {
            $page->blocks2 = [];
        }



		$this->design->assign('page', $page);
		
 	  	$menus = $this->pages->get_menus();
		$this->design->assign('menus', $menus);
		
	    // Текущее меню
	    if(isset($page->menu_id))
	  		$menu_id = $page->menu_id; 
	  	if(empty($menu_id) || !$menu = $this->pages->get_menu($menu_id))
	  	{
	  		$menu = reset($menus);
	  	}
	 	$this->design->assign('menu', $menu);
		
		// All pages
		$pages = $this->pages->get_pages(array('menu_id'=>$menu->id));
		$pages = $this->pages->get_pages_tree();
		$this->design->assign('pages', $pages);

		unset($this->categories_tree->categories_tree['pages']);
		$services = $this->pages->get_pages(array('menu_id'=>5));
		$services = $this->pages->get_pages_tree();
		$this->design->assign('services', $services);
		
		// Houses
		if ($page->menu_id == 5) {
			$applications_pages = $this->pages->get_pages([
				'menu_id' => 15
			]);
			$this->design->assign('applications_pages', $applications_pages);

            $this->design->assign('neighborhoods', $this->pages->get_pages(['menu_id' => 16]));
		}


		$tpl = 'page.tpl';

		if($menu->id == 12) // For House Leader (chacklists)
			$tpl = 'page_houseleader.tpl';
		elseif($page->id == 275)
			$tpl = 'page_checklist.tpl';
		
 	  	return $this->design->fetch($tpl);
	}
	
}

