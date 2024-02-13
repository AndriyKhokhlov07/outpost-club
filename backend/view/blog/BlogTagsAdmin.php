<?PHP

require_once('api/Backend.php');


class BlogTagsAdmin extends Backend
{
	function fetch()
	{
		if($this->request->method('post'))
		{
			// Действия с выбранными
			$ids = $this->request->post('check');
			if(is_array($ids))
			switch($this->request->post('action'))
			{
			    case 'disable':
			    {
			    	foreach($ids as $id)
						$this->blog->update_tag($id, array('visible'=>0));    
					break;
			    }
			    case 'enable':
			    {
			    	foreach($ids as $id)
						$this->blog->update_tag($id, array('visible'=>1));    
			        break;
			    }
			    case 'delete':
			    {
					$this->blog->delete_tag($ids);    
			        break;
			    }
			}		
	  	
			// Сортировка
			$positions = $this->request->post('positions');
	 		$ids = array_keys($positions);
			sort($positions);
			foreach($positions as $i=>$position)
				$this->blog->update_tag($ids[$i], array('position'=>$position)); 

		} 
		 
		$tags = array();
		$tags_ = $this->blog->get_tags_list();
		if(!empty($tags_))
		{
			foreach($tags_ as $t)
				$tags[$t->id] = $t;
		}
			
		
		$this->design->assign('tags', $tags);
		return $this->design->fetch('blog/tags.tpl');
	}
}
