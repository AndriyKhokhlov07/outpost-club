<?PHP

require_once('View.php');

class GalleriesView extends View
{
	function fetch()
	{
		
		// Категории
		$url = $this->request->get('galleries_category', 'string');
		$category = $this->galleries->get_category($url);
		
		$this->galleries->get_categories(array('visible'=>1));
		$galleries_categories = $this->galleries->get_categories_tree();
		if(!empty($category)) // Категории с подкатегориями
			$category = $this->galleries->get_category_i((int)$category->id);
			
		// Галереи
		if(!empty($category))
			$filter['category_id'] = $category->children;
		$filter['visible'] = 1;
		
		$galleries = array();
		foreach($this->galleries->get_galleries($filter) as $gallery)
			$galleries[$gallery->id] = $gallery;
			
		//print_r($category->children); exit;
		
		if(!empty($galleries))	
			foreach($this->galleries->get_images(array('gallery_id'=>array_keys($galleries), 'main'=>1)) as $image)
				$galleries[$image->gallery_id]->image = $image->filename;
			
		foreach($galleries as $g)
			if(empty($g->image))
				unset($galleries[$g->id]);
		
		$this->design->assign('galleries', $galleries);
		$this->design->assign('galleries_categories', $galleries_categories);
		
		if(!empty($category))
		{
			$this->design->assign('galleries_category', $category);
			$this->design->assign('meta_title', $category->meta_title);
			$this->design->assign('meta_keywords', $category->meta_keywords);
			$this->design->assign('meta_description', $category->meta_description);
		}
			
		return $this->design->fetch('galleries.tpl');
	}
}