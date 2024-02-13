{* Вкладки *}
{capture name=tabs}
	{if in_array('orders', $manager->permissions)}
	<li {if $status===0}class="active"{/if}><a href="{url module=OrdersAdmin status=0 type=1 keyword=null id=null page=null label=null}">New invoices</a></li>
	<li {if $status===0}class="active"{/if}><a href="{url module=OrdersAdmin status=0 type=2 keyword=null id=null page=null label=null}">New orders</a></li>
	<li {if $status==1}class="active"{/if}><a href="{url module=OrdersAdmin status=1 keyword=null id=null page=null label=null}">Pending</a></li>
	<li {if $status==2}class="active"{/if}><a href="{url module=OrdersAdmin status=2 keyword=null id=null page=null label=null}">Paid</a></li>
	<li {if $status==3}class="active"{/if}><a href="{url module=OrdersAdmin status=3 keyword=null id=null page=null label=null}">Canceled</a></li>
	{if $keyword}
	<li class="active"><a href="{url module=OrdersAdmin keyword=$keyword id=null label=null}">Поиск</a></li>
	{/if}
	{/if}
	<li class="active"><a href="{url module=OrdersLabelsAdmin keyword=null id=null page=null label=null}">Labels</a></li>
{/capture}

{* Title *}
{$meta_title='Orders labels' scope=parent}

{* Заголовок *}
<div id="header">
	<h1>{if $labels}Orders labels{else}No labels{/if}</h1>
	<a class="add" href="{url module=OrdersLabelAdmin}">New label</a>
</div>

{if $labels}
<div id="main_list">
 
	<form id="list_form" method="post">
		<input type="hidden" name="session_id" value="{$smarty.session.id}">
		<div id="list">		
			{foreach $labels as $label}
			<div class="row">
				<input type="hidden" name="positions[{$label->id}]" value="{$label->position}">
				<div class="move cell"><div class="move_zone"></div></div>
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$label->id}" />				
				</div>
				<div class="name cell">
					<span style="background-color:#{$label->color};" class="order_label"></span>
					<a href="{url module=OrdersLabelAdmin id=$label->id return=$smarty.server.REQUEST_URI}">{$label->name|escape}</a>
				</div>
				<div class="icons cell">
					<a class="delete" title="Delete" href="#"></a>
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
	
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id="select">
		<select name="action">
			<option value="delete">Delete</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Apply">
	
		</div>
	</form>	
</div>
{else}
	No labels
{/if}

{* On document load *}
{literal}
<script>
$(function() {

	// Сортировка списка
	$("#list").sortable({
		items:             ".row",
		tolerance:         "pointer",
		handle:            ".move_zone",
		scrollSensitivity: 40,
		opacity:           0.7, 
		forcePlaceholderSize: true,
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

 
	// Раскраска строк
	function colorize()
	{
		$(".row:even").addClass('even');
		$(".row:odd").removeClass('even');
	}
	// Раскрасить строки сразу
	colorize();
 

	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:checked)').length>0);
	});	

	// Delete 
	$("a.delete").click(function() {
		$('#list_form input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});
	
	// Подтверждение удаления
	$("form").submit(function() {
		if($('#list input[type="checkbox"][name*="check"]:checked').length>0)
			if($('select[name="action"]').val()=='delete' && !confirm('Please, confirm deletion'))
				return false;	
	});
});
</script>
{/literal}
