<?
session_start();
chdir('..');
require_once('api/Backend.php');
$backend = new Backend();

$type = $backend->request->post('type');
$rating = $backend->request->post('rating', 'integer');

if($type=='page')
{
	$page_id = $backend->request->post('page_id', 'integer');

	$page = $backend->pages->get_page(intval($page_id));
	if(!empty($page))
	{
		if(empty($_COOKIE['pg_'.$page_id]) || isset($_SESSION['admin'])){
			$page->rating = $page->rating + $rating;
			$page->votes++;
			$backend->pages->update_page((int)$page->id, array('votes'=>$page->votes, 'rating'=>$page->rating));
		}
		elseif(isset($_COOKIE['pg_'.$page_id]) && !isset($_SESSION['admin'])){
			$page->rating = $page->rating - (int)$_COOKIE['pg_'.$page_id] + $rating;
			$backend->pages->update_page((int)$page->id, array('rating'=>$page->rating));
		}

		$expire = time()+60*60*24; // Время жизни - 1 день

		setcookie('pg_'.$page_id, $rating, $expire, "/");

		$backend->design->assign('page', $page);

		$result['rating'] = $backend->design->fetch('page_rating.tpl');
		//$result['rating'] = $rating.'/ '.$page->rating.'/ '.$_COOKIE['r_'.$page_id];
	}
}
else
{
	$post_id = $backend->request->post('page_id', 'integer');

	$post = $backend->blog->get_post(intval($post_id));
	if(!empty($post))
	{
		if(empty($_COOKIE['pt_'.$post_id]) || isset($_SESSION['admin'])){
			$post->rating = $post->rating + $rating;
			$post->votes++;
			$backend->blog->update_post((int)$post->id, array('votes'=>$post->votes, 'rating'=>$post->rating));
		}
		elseif(isset($_COOKIE['pt_'.$post_id]) && !isset($_SESSION['admin'])){
			$post->rating = $post->rating - (int)$_COOKIE['pt_'.$post_id] + $rating;
			$backend->blog->update_post((int)$post->id, array('rating'=>$post->rating));
		}

		$expire = time()+60*60*24; // Время жизни - 1 день

		setcookie('pt_'.$post_id, $rating, $expire, "/");

		$backend->design->assign('post', $post);

		$result['rating'] = $backend->design->fetch('post_rating.tpl');
		//$result['rating'] = $rating.'/ '.$post->rating.'/ '.$_COOKIE['r_'.$post_id];
	}	
}






header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");
echo json_encode($result);