{* Вкладки *}
{capture name=tabs}
	<li><a href="index.php?module=BlogAdmin&type=1">Blog</a></li>
	<!-- <li {if $type==2} class="active" {/if}><a href="index.php?module=BlogAdmin&type=2">Reviews</a></li> -->
	<li class="active"><a href="index.php?module=AuthorsAdmin">Authors</a></li>
	<li><a href="index.php?module=BlogTagsAdmin">Tags</a></li>
{/capture}

{if $author->id}
{$meta_title = $author->name scope=parent}
{else}
{$meta_title = 'New author' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

{* On document load *}

<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>

<script type="text/javascript" src="{$config->root_url}/js/fancybox/jquery.fancybox.min.js"></script>
<link rel="stylesheet" href="{$config->root_url}/js/fancybox/jquery.fancybox.min.css" type="text/css" media="screen" />
{literal}

<script>
$(function() {
	
	// Зум картинок
	$("a.zoom").fancybox({prevEffect: 'fade', nextEffect: 'fade'});	

	// Удаление изображений
	$(".images a.delete").click( function() {
		$(this).closest(".images").find("input[name*='delete_image']").val('1');
		$(this).closest("ul").fadeOut(200, function() { $(this).remove(); });
		return false;
	});
	
	// Удалить 
	$(".languages a.del").click(function() {
		$(this).closest("form").find('input[name="action"]').val('delete');
		$(this).closest("form").submit();
	});

	
	// Подтвердить удаление
	$("form").submit(function() {
		if($('input[name="action"]').val()=='delete' && !confirm('Please, confirm deletion')){
			$('input[name="action"]').val('');
			return false;
		}
	});



url_touched = true;

if($('input[name="url"]').val() == generate_url() || $('input[name="url"]').val() == '')
	url_touched = false;

$('input[name="url"]').change(function() { url_touched = true; });
$('input[name="name"]').keyup(function() { set_meta(); });

function set_meta()
{
	if(!url_touched)
		$('input[name="url"]').val(generate_url());
}


function generate_url()
{
	url = $('input[name="name"]').val();
	url = url.replace(/[\s]+/gi, '-');
	url = translit(url);
	url = url.replace(/[^0-9a-z_\-]+/gi, '').toLowerCase();	
	return url;
}

function translit(str)
{
	var ru=("А-а-Б-б-В-в-Ґ-ґ-Г-г-Д-д-Е-е-Ё-ё-Є-є-Ж-ж-З-з-И-и-І-і-Ї-ї-Й-й-К-к-Л-л-М-м-Н-н-О-о-П-п-Р-р-С-с-Т-т-У-у-Ф-ф-Х-х-Ц-ц-Ч-ч-Ш-ш-Щ-щ-Ъ-ъ-Ы-ы-Ь-ь-Э-э-Ю-ю-Я-я").split("-")   
	var en=("A-a-B-b-V-v-G-g-G-g-D-d-E-e-E-e-E-e-ZH-zh-Z-z-I-i-I-i-I-i-J-j-K-k-L-l-M-m-N-n-O-o-P-p-R-r-S-s-T-t-U-u-F-f-H-h-TS-ts-CH-ch-SH-sh-SCH-sch-'-'-Y-y-'-'-E-e-YU-yu-YA-ya").split("-")   
 	var res = '';
	for(var i=0, l=str.length; i<l; i++)
	{ 
		var s = str.charAt(i), n = ru.indexOf(s); 
		if(n >= 0) { res += en[n]; } 
		else { res += s; } 
    } 
    return res;  
}
  
});

</script>
 
{/literal}


{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success=='added'}Author added{elseif $message_success=='updated'}Author updated{else}{$message_success}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error=='url_exists'}Author with this url already exists{else}{$message_error}{/if}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}


<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$author->name|escape}"/> 
		<input name=id type="hidden" value="{$author->id|escape}"/>
        <input name=content_id type="hidden" value="{$author->content_id|escape}"/>
        <input name=action type="hidden" value="0"/> 
        {if $author->id}
        	<input name=language_id type="hidden" value="{$author->language_id|escape}"/>
        {/if}
		<div class="checkbox">
			<input name=visible value='1' type="checkbox" id="active_checkbox" {if $author->visible}checked{/if}/> <label for="active_checkbox">Active</label>
		</div>
	</div>


		
	<!-- Левая колонка -->
	<div id="column_left">
			
		<!-- Параметры страницы -->
		<div class="block layer">
			<ul>
				<li><label class=property>Post</label><input name="post" class="backend_inp" type="text" value="{$author->post|escape}" /></li>
				<li><label class=property>Url</label><input name="url" class="backend_inp" type="text" value="{$author->url|escape}" /></li>
			</ul>
		</div>
		<!-- Параметры страницы (The End)-->
			
	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
	<!-- Правая колонка свойств товара -->	
	<div id="column_right">
		
		<!-- Изображение категории -->	
		<div class="block layer images image_file">
			<h2>Image</h2>
			<input class='upload_image' name=image type=file>			
			<input type=hidden name="delete_image" value="">
			{if $author->image}
			<ul>
				<li>
					<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
					<a class="zoom" rel="group" href="../{$config->authors_images_dir}{$author->image}"><img src="{$author->image|resize:author:100:100}" alt="" /></a>
				</li>
			</ul>
			{/if}
		</div>        
	</div>
	<!-- Правая колонка свойств товара (The End)--> 


	<!-- Описагние категории -->
	<div class="block layer">
		<h2>Text</h2>
		<textarea name="text" class="editor_large">{$author->text|escape}</textarea>
	</div>
	<!-- Описание категории (The End)-->
	<input class="button_green button_save" type="submit" name="" value="Submit" />
	
</form>
<!-- Основная форма (The End) -->

