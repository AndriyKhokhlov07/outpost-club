<?PHP
require_once('api/Backend.php');

class FarewellAdmin extends Backend
{	
	
	public function fetch()
	{	
 	  	return $this->design->fetch('form_farewell.tpl');
	}
	
}

