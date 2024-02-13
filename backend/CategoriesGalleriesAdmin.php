<?PHP 

require_once('api/Backend.php');

########################################
class CategoriesGalleriesAdmin extends Backend
{

  public function fetch()
  {

   	// Обработка действий
  	if($this->request->method('post'))
  	{
		// Сортировка
		$positions = $this->request->post('positions'); 		
 		$ids = array_keys($positions);
		sort($positions);
		foreach($positions as $i=>$position)
			$this->galleries->update_category($ids[$i], array('position'=>$position)); 

		
		// Действия с выбранными
		$ids = $this->request->post('check');
		if(is_array($ids))
		switch($this->request->post('action'))
		{
		    case 'disable':
		    {
				$this->galleries->update_category($ids, array('visible'=>0));	      
				break;
		    }
		    case 'enable':
		    {
				$this->galleries->update_category($ids, array('visible'=>1));	      
		        break;
		    }
		    case 'delete':
		    {
			    foreach($ids as $id)
					$this->galleries->delete_category($id);    
		        break;
		    }
		}		
		
 	}


	// Отображение
  	//$pages = $this->galleries->get_categories();
	$categories = $this->galleries->get_categories_tree();

 	$this->design->assign('categories', $categories);
	return $this->design->fetch('galleries_categories.tpl');
  }
}


?>