<?PHP
require_once('api/Backend.php');

class MoveInAdmin extends Backend
{	
	
	public function fetch()
	{	
 	  	return $this->design->fetch('form_movein.tpl');
	}
	
}

