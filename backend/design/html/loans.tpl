{* Вкладки *}
{capture name=tabs}
	{if in_array('pages', $manager->permissions)}
	{foreach from=$menus item=m}
		<li><a href="{url module=PagesAdmin menu_id=$m->id}">{$m->name}</a></li>
	{/foreach}
	{/if}
	<li class="active"><a href="{url module=LoansAdmin menu_id=null}">Вадачи</a></li>
	<li><a href="{url module=GalleryAdmin id=1 menu_id=null}">Благодарности</a></li>
{/capture}

{* Title *}
{$meta_title = 'Вадачи' scope=parent}

{* Заголовок *}
<div id="header">
	<h1>Выдачи</h1>
	<a class="add" href="{url module=LoanAdmin id=null}">Добавить выдачу</a>
</div>

{if $loans}
<div id="main_list">
 
	<form id="list_form" method="post">
		<input type="hidden" name="session_id" value="{$smarty.session.id}">
		<!--<div id="list">	-->
		<div id="list" class="sortable">
			{foreach $loans as $loan}
			<div class="{if !$loan->visible}invisible{/if} row">
				<input type="hidden" name="positions[{$loan->id}]" value="{$loan->position}">
				<div class="move cell"><div class="move_zone"></div></div>
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$loan->id}" />				
				</div>
				<div class="name cell">
					<a href="{url module=LoanAdmin id=$loan->id return=$smarty.server.REQUEST_URI}">{$loan->name|strip_tags}</a>
					<p>{$loan->price|escape}</p>
				</div>
				<div class="icons cell">
					<a class="enable" title="Активна" href="#"></a>
					<a class="delete" title="Удалить" href="#"></a>
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div> 
	
		<div id="action">
		<label id="check_all" class="dash_link">Выбрать все</label>
	
		<span id="select">
		<select name="action">
			<option value="enable">Сделать видимыми</option>
			<option value="disable">Сделать невидимыми</option>
			<option value="delete">Удалить</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Применить">
	
		</div>
	</form>	
</div>
{else}
	Нет выдач
{/if}


<div id="right_menu">
	<ul>
		<li {if !$type}class="selected"{/if}><a href="{url type=null}">Все</a></li>
		<li {if $type==2}class="selected"{/if}><a href="{url type=2}">Недвижимость</a></li>
		<li {if $type==1}class="selected"{/if}><a href="{url type=1}">Авто в ходу</a></li>
		<li {if $type==3}class="selected"{/if}><a href="{url type=3}">Авто на стоянке</a></li>

	</ul>
</div>

{* On document load *}
{literal}
<script>
$(function() {

	// Сортировка списка
	$(".sortable").sortable({
		items:             ".row",
		tolerance:         "pointer",
		handle:            ".move_zone",
		scrollSensitivity: 40,
		opacity:           0.7, 
		//forcePlaceholderSize: true,
		axis: 'y',
		
		helper: function(event, ui){		
			if($('input[type="checkbox"][name*="check"]:checked').size()<1) return ui;
			var helper = $('<div/>');
			$('input[type="checkbox"][name*="check"]:checked').each(function(){
				var item = $(this).closest('.row');
				helper.height(helper.height()+item.innerHeight());
				if(item[0]!=ui[0]) {
					helper.append(item.clone());
					$(this).closest('.row').remove();
				}
				else {
					helper.append(ui.clone());
					item.find('input[type="checkbox"][name*="check"]').attr('checked', false);
				}
			});
			return helper;			
		},	
 		start: function(event, ui) {
  			if(ui.helper.children('.row').size()>0)
				$('.ui-sortable-placeholder').height(ui.helper.height());
		},
		beforeStop:function(event, ui){
			if(ui.helper.children('.row').size()>0){
				ui.helper.children('.row').each(function(){
					$(this).insertBefore(ui.item);
				});
				ui.item.remove();
			}
		},
		update:function(event, ui)
		{
			$("#list_form input[name*='check']").attr('checked', false);
			$("#list_form").ajaxSubmit(function() {
				colorize();
			});
		}
	});

	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:checked)').length>0);
	});	

	// Удалить 
	$("a.delete").click(function() {
		$('#list_form input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});
	

	// Показать
	$("a.enable").click(function() {
		var icon        = $(this);
		var line        = icon.closest(".row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('invisible')?1:0;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'loan', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
			success: function(data){
				icon.removeClass('loading_icon');
				if(state)
					line.removeClass('invisible');
				else
					line.addClass('invisible');				
			},
			dataType: 'json'
		});	
		return false;	
	});


	$("form").submit(function() {
		if($('select[name="action"]').val()=='delete' && !confirm('Подтвердите удаление'))
			return false;	
	});
});
</script>
{/literal}
