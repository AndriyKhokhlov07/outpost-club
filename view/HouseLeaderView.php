<?php


require_once('View.php');

class HouseLeaderView extends View
{
	public function fetch()
	{
		if(empty($this->user))
		{
			header('Location: '.$this->config->root_url.'/user/login');
			exit();
		}
		if($this->user->type!=2)
		{
			header('Location: '.$this->config->root_url.'/current-members');
			exit();
		}
		

		$this->pages->all_pages = array();
		$hl_pages = $this->pages->get_pages(array('menu_id'=>12, 'visible'=>1));
		if(!empty($hl_pages))
		{
			$this->design->assign('hl_pages', $this->categories_tree->get_categories_tree('hl_pages', $hl_pages));
		}
		
		
		$this->design->assign('meta_title', 'House Leader');
		return $this->design->fetch('houseleader.tpl');
	}
}
