<?PHP

/**
 * Backend CMS
 * Storefront class: Каталог товаров
 *
 * Этот класс использует шаблоны hits.tpl
 *
 * @copyright 	2010 Denis Pikusov
 * @link 		http://backendcms.ru
 * @author 		Denis Pikusov
 *
 * 
 *
 */
 
require_once('View.php');


class MainView extends View
{

	function fetch()
	{
		if ($this->page) {
			$this->design->assign('meta_title', $this->page->meta_title);
			$this->design->assign('meta_keywords', $this->page->meta_keywords);
			$this->design->assign('meta_description', $this->page->meta_description);
		}

		$this->design->assign('loans', $this->loans->get_loans(array('visible'=>1)));

		return $this->design->fetch('main.tpl');
	}
}
