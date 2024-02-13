{$subject="Request from" scope=parent}
{if $subject_}
	{$subject = $subject_ scope=parent}
{/if}
{$st = 1000}
{if $step == 1}
	{$st = 7}
{/if}

{* <h1 style="font-weight:normal;font-family:arial;">{$subject}</h1> *}

<table cellpadding="6" cellspacing="0" style="border-collapse: collapse;">
{if $data}
	{$n = 0}
	{foreach $data as $d}
    {if $d->name=='clear'}
        <tr>
            <td colspan="2" style="padding:10px; background-color:#fff; border:1px solid #fff; border-bottom:1px solid #e0e0e0;"></td>
        </tr>
 	{else if is_array($d->value)}
        {foreach $d->value as $v}
        <tr>
			<td style="padding:6px; width:170; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
				{$d->name|escape}
            </td>
            <td style="padding:6px; width:330; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
				{$v}
            </td>
		</tr>
        {/foreach}
    {else}
        {if $st > $n}
        <tr>
			<td style="padding:6px; width:170; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
				{$d->name|escape}
            </td>
            {if $d->images}
            <td style="padding:6px; width:330; background-color:#fff; border:1px solid #e0e0e0;font-family:arial;">
                {foreach $d->images as $i}
                    <a href="{$i}" target="_blank">
                        <img src="{$i}" alt="" width="100">
                    </a>
                {/foreach}
            </td>
            {else}
            <td style="padding:6px; width:330; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
				{$d->value}
            </td>
            {/if}
		</tr>
        {/if}
        {$n=$n+1}
	{/if}
    {/foreach}
{/if}
</table>