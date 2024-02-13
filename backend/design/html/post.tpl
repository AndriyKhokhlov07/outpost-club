{capture name=tabs}
	<li {if $type==1} class="active" {/if}><a href="index.php?module=BlogAdmin&type=1">Blog</a></li>
	<li {if $type==2} class="active" {/if}><a href="index.php?module=BlogAdmin&type=2">Reviews</a></li>
	<li><a href="index.php?module=AuthorsAdmin">Authors</a></li>
	<li><a href="index.php?module=BlogTagsAdmin">Tags</a></li>
{/capture}

{if $post->id}
{$meta_title = $post->name scope=parent}
{else}
{$meta_title = 'New post' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

{* On document load *}
{literal}
<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>
<script src="design/js/autocomplete/jquery.autocomplete-min.js"></script>
<script src="design/js/jquery/datepicker/jquery.ui.datepicker-en.js"></script>

<script src="design/js/jquery/timepicker/jquery-ui-timepicker-addon.js"></script>

<link rel="stylesheet" href="design/js/jquery/timepicker/jquery-ui-timepicker-addon.css">


<script>
$(function() {
	
	// Удаление изображений
	$(".images a.delete").click( function() {
		$("input[name='delete_image']").val('1');
		$(this).closest("ul").fadeOut(200, function() { $(this).remove(); });
		return false;
	});
	

	$('input[name="date"]').datepicker({
		regional:'en'
	});


	$('input[name="date_modified"]').datetimepicker({
		regional: 'en',
		dateFormat: "yy-mm-dd",
		timeFormat: "HH:mm:ss"
	});

	// Добавление тега
	$('#post_tags .add').click(function() {
		$("#post_tags ul li:last").clone(false).appendTo('#post_tags ul').fadeIn('slow').find("select[name*=tags]:last").focus();
		$("#post_tags ul li:last span.add").hide();
		$("#post_tags ul li:last span.delete").show();
		return false;		
	});

	// Удаление тега
	$("#post_tags .delete").live('click', function() {
		$(this).closest("li").fadeOut(200, function() { $(this).remove(); });
		return false;
	});

	// Удаление автора
	$(".post_authors a.delete").live('click', function() {
		 $(this).closest("div.row").fadeOut(200, function() { $(this).remove(); });
		 return false;
	});
	// Добавление автора
	var new_author = $('#new_author').clone(true);
	$('#new_author').remove().removeAttr('id');
 
	$("input.add_author").autocomplete({
		serviceUrl:'ajax/get_authors.php',
		minChars:0,
		noCache: false, 
		onSelect:
			function(suggestion){
				$("input.add_author").val('').focus().blur(); 
				new_item = new_author.clone().appendTo('.post_authors');
				new_item.removeAttr('id');
				new_item.find('a.author_name')
					.attr('href', 'index.php?module=AuthorAdmin&id='+suggestion.data.id)
					.html(suggestion.data.name);
				new_item.find('input[name*="post_authors"]').val(suggestion.data.id);
				if(suggestion.data.image)
					new_item.find('.image img').attr("src", suggestion.data.image);
				else
					new_item.find('.image img').remove();
				new_item.show();
			},
		formatResult:
			function(suggestions, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
  				return (suggestions.data.image?"<img align=absmiddle src='"+suggestions.data.image+"'> ":'') + suggestions.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
			}
	});
	
	// Автозаполнение мета-тегов
	meta_title_touched = true;
	meta_keywords_touched = true;
	meta_description_touched = true;
	url_touched = true;
	
	if($('input[name="meta_title"]').val() == generate_meta_title() || $('input[name="meta_title"]').val() == '')
		meta_title_touched = false;
	if($('input[name="meta_keywords"]').val() == generate_meta_keywords() || $('input[name="meta_keywords"]').val() == '')
		meta_keywords_touched = false;
	if($('textarea[name="meta_description"]').val() == generate_meta_description() || $('textarea[name="meta_description"]').val() == '')
		meta_description_touched = false;
	if($('input[name="url"]').val() == generate_url() || $('input[name="url"]').val() == '')
		url_touched = false;
		
	$('input[name="meta_title"]').change(function() { meta_title_touched = true; });
	$('input[name="meta_keywords"]').change(function() { meta_keywords_touched = true; });
	$('textarea[name="meta_description"]').change(function() { meta_description_touched = true; });
	$('input[name="url"]').change(function() { url_touched = true; });
	
	$('input[name="name"]').keyup(function() { set_meta(); });
	$('select[name="brand_id"]').change(function() { set_meta(); });
	$('select[name="categories[]"]').change(function() { set_meta(); });
	
});

function set_meta()
{
	if(!meta_title_touched)
		$('input[name="meta_title"]').val(generate_meta_title());
	if(!meta_keywords_touched)
		$('input[name="meta_keywords"]').val(generate_meta_keywords());
	if(!meta_description_touched)
	{
		descr = $('textarea[name="meta_description"]');
		descr.val(generate_meta_description());
		descr.scrollTop(descr.outerHeight());
	}
	if(!url_touched)
		$('input[name="url"]').val(generate_url());
}

function generate_meta_title()
{
	name = $('input[name="name"]').val();
	return name;
}

function generate_meta_keywords()
{
	name = $('input[name="name"]').val();
	return name;
}

function generate_meta_description()
{
	if(typeof(tinyMCE.get("annotation")) =='object')
	{
		//description = tinyMCE.get("annotation").getContent().replace(/(<([^>]+)>)/ig," ").replace(/(\&nbsp;)/ig," ").replace(/^\s+|\s+$/g, '').substr(0, 512);
		//return description;
	}
	else
		return $('textarea[name=annotation]').val().replace(/(<([^>]+)>)/ig," ").replace(/(\&nbsp;)/ig," ").replace(/^\s+|\s+$/g, '').substr(0, 512);
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

</script>
{/literal}

{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success == 'added'}{$post->name|escape} was created{elseif $message_success == 'updated'}{$post->name|escape} was updated{/if}</span>
	<a class="link" target="_blank" href="../blog/{$post->url}">View post page</a>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
	{*
	<span class="share">		
		<a href="#" onClick='window.open("http://vkontakte.ru/share.php?url={$config->root_url|urlencode}/blog/{$post->url|urlencode}&title={$post->name|urlencode}&description={$post->annotation|urlencode}&noparse=false","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/vk_icon.png" /></a>
		<a href="#" onClick='window.open("http://www.facebook.com/sharer.php?u={$config->root_url|urlencode}/blog/{$post->url|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/facebook_icon.png" /></a>
		<a href="#" onClick='window.open("http://twitter.com/share?text={$post->name|urlencode}&url={$config->root_url|urlencode}/blog/{$post->url|urlencode}&hashtags={$post->meta_keywords|replace:' ':''|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/twitter_icon.png" /></a>
	</span>
	*}
	
	
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error == 'url_exists'}Post with the same URL already exists{/if}</span>
	{if $smarty.get.return}
		<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
	</div>
<!-- Системное сообщение (The End)-->
{/if}


<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$post->name|escape}"/> 
		<input name=id type="hidden" value="{$post->id|escape}"/> 
		<div class="checkbox">
			<input name=visible value='1' type="checkbox" id="active_checkbox" {if $post->visible}checked{/if}/> <label for="active_checkbox">Published</label>
		</div>
	
	</div> 

	<div id="post_type" class="block">
		<label class=property>Type</label>
		<select name="type">
            <option value='1' {if $type == 1}selected{/if}>Post</option>
            <option value='2' {if $type == 2}selected{/if}>Review</option>
		</select>
	</div>

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
		
		<!-- Параметры страницы -->
		<div class="block">
			<ul>
				<li><label class=property>Date</label><input type=text name=date value='{$post->date|date}'></li>
				<li><label class=property>Date modified</label><input type=text name=date_modified value='{$post->date_modified}'></li>
			</ul>

		</div>
		<div class="block layer">
		<!-- Параметры страницы (The End)-->
			<h2>Page properties</h2>
		<!-- Параметры страницы -->
			<ul>
				<li><label class=property>URL</label><div class="page_url"> /blog/</div><input name="url" class="page_url" type="text" value="{$post->url|escape}" /></li>
				<li><label class=property>Old url</label><input name="old_url" class="backend_inp" type="text" value="{$post->old_url|escape}" />
				{if $post->old_url}<a href="{$config->root_url}/{$post->old_url|escape}" target="_blank" style="margin:5px 0 10px 170px">Check redirect</a>{/if}
				</li>
				<li><label class=property>Title</label><input name="meta_title" type="text" value="{$post->meta_title|escape}" /></li>
				<li><label class=property>Keywords</label><input name="meta_keywords"  type="text" value="{$post->meta_keywords|escape}" /></li>
				<li><label class=property>Description</label><textarea name="meta_description" />{$post->meta_description|escape}</textarea></li>
			</ul>
		</div>
		{if $type != 2}

		<!-- Параметры страницы (The End)-->
		<div class="block layer">
			<ul>
				<li>
					<label class=property><h2>Tag</h2></label>
					<div id="post_tags" {if !$tags}style='display:none;'{/if}>
						<div>
							<ul>
								{foreach $post_tags as $post_tag name=p_tags}
								<li>
									<select name="tags[]">
										{if $level==0}
											<option value='0'>-- no select --</option>
										{/if}
										{foreach $tags as $tag}
												<option value='{$tag->id}' {if $tag->id == $post_tag->tag_id}selected{/if} tag_name='{$tag->name|escape}'>{$tag->name|escape}</option>
										{/foreach}
									</select>
									<span {if not $smarty.foreach.p_tags.first}style='display:none;'{/if} class="add"><i class="dash_link">Add tag</i></span>
									<span {if $smarty.foreach.p_tags.first}style='display:none;'{/if} class="delete"><i class="dash_link">Delete</i></span>
								</li>
								{/foreach}		
							</ul>
						</div>
					</div>
				</li>
			</ul>
		</div>
		
		<div class="block layer">
			<h2>Author</h2>
			<div id=list class="sortable post_authors">
				{if $post_authors}
					{foreach $post_authors as $post_author}
					<div class="row">
						<div class="move cell">
							<div class="move_zone"></div>
						</div>
						<div class="image cell">
						<input type=hidden name=post_authors[] value='{$post_author->id}'>
						<a href="index.php?module=AuthorAdmin&id={$post_author->id}&content_id={$post_author->content_id}&language_id={$post_author->language_id}" target="_blank">
						<img src='{$post_author->image|resize:author:35:35}'>
						</a>
						</div>
						<div class="name cell">
						<a href="index.php?module=AuthorAdmin&id={$post_author->id}&content_id={$post_author->content_id}&language_id={$post_author->language_id}" target="_blank">{$post_author->name}</a>
						</div>
						<div class="icons cell">
						<a href='#' class="delete"></a>
						</div>
						<div class="clear"></div>

					</div>
					{/foreach}
				{/if}
				<div id="new_author" class="row" style='display:none;'>
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type=hidden name=post_authors[] value=''>
					<img src=''>
					</div>
					<div class="name cell">
					<a class="author_name" href="" target="_blank"></a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
			</div>
			<input type=text name=sp class="add_author input_autocomplete" placeholder='Select author'>
		</div>
			
		{/if}
	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
	<!-- Правая колонка свойств товара -->	
	<div id="column_right">
    
    	<!-- Изображение -->	
		<div class="block images">
			<h2>Image</h2>
			<input class='upload_image' name=image type=file>			
			<input type=hidden name="delete_image" value="">
			{if $post->image}
			<ul>
				<li>
					<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
                    <img src="{$post->image|resize:blog:100:100}" alt="" />
				</li>
			</ul>
			{/if}
		</div>
		
	</div>
	<!-- Правая колонка свойств товара (The End)--> 
	
	<!-- Описагние товара -->
	<div class="block layer">
		<h2>Annotation</h2>
		<textarea name="annotation" class='editor_small'>{$post->annotation|escape}</textarea>
	</div>
		
	<div class="block">
		<h2>Text</h2>
		<textarea name="body"  class='editor_large'>{$post->text|escape}</textarea>
	</div>
	<!-- Описание товара (The End)-->
	<input class="button_green button_save" type="submit" name="" value="Save" />
	
</form>
<!-- Основная форма (The End) -->
