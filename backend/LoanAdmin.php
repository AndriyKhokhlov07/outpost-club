<?PHP
require_once('api/Backend.php');

class LoanAdmin extends Backend
{	
	private $allowed_image_extentions = array('png', 'gif', 'jpg', 'jpeg', 'ico');
	
	public function fetch()
	{	
		$loan = new stdClass;
		if($this->request->method('POST'))
		{	
			$loan->id = $this->request->post('id', 'integer');
			$loan->type = $this->request->post('type', 'integer');
			$loan->name = $this->request->post('name');
			$loan->price = $this->request->post('price');
			$loan->description = $this->request->post('description');
			$loan->visible = $this->request->post('visible', 'boolean');
				

			if(empty($loan->id))
			{
  				$loan->id = $this->loans->add_loan($loan);
  				$loan = $this->loans->get_loan($loan->id);
  				$this->design->assign('message_success', 'added');
	    		}
	    		else
	    		{
	    			$this->loans->update_loan($loan->id, $loan);
  				$loan = $this->loans->get_loan($loan->id);
  				$this->design->assign('message_success', 'updated');
	    		}
				// Удаление изображения
	    		if($this->request->post('delete_image')){
	    			$this->loans->delete_image($loan->id);
				if(!empty($loan->image))
					unset($loan->image);
	    		}
	    		// Загрузка изображения
	    		$image = $this->request->files('image');
	    		if(!empty($image['name']) && in_array(strtolower(pathinfo($image['name'], PATHINFO_EXTENSION)), $this->allowed_image_extentions)){
	    			$this->loans->delete_image($loan->id);	    			
	    			move_uploaded_file($image['tmp_name'], $this->root_dir.$this->config->loans_images_dir.$image['name']);
	    			$this->loans->update_loan($loan->id, array('image'=>$image['name']));
				$loan->image = $image['name'];
	    		}
		}
		else
		{
			$id = $this->request->get('id', 'integer');
			if(!empty($id))
				$loan = $this->loans->get_loan(intval($id));			
			else
				$loan->visible = 1;
		}	

		$this->design->assign('loan', $loan);
		
 	  	$menus = $this->pages->get_menus();
		$this->design->assign('menus', $menus);
		
 	  	return $this->design->fetch('loan.tpl');
	}
	
}

