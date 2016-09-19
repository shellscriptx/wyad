#!/bin/bash

# ------------------------------------------------------------------------------------------------------
# Data 19 de Setembro de 2016
# Criado por: Juliano Santos [x_SHAMAN_x]
# Script: wyad (POO)
# Página: https://www.facebook.com/shellscriptx
# email:  juliano.santos.bm@gmail.com
#
# Descrição: Script que simula um POO utilizando o comando yad que é um fork do zenity para criação
#			 de interfaces (gtk).
#			 O objetivo aqui não é criar uma programação complexa orientada a objeto, mas a capacidade
#			 do 'bash' de simular uma.
# Uso:
#			 Importando o 'wyad' para seu script/projeto:
#			 Insira a linha abaixo no inicio do script.
#
#			 . wyad.sh ou source wyad.sh
#
# Notas:	
#			 O modelo genérico criado utiliza a seguinte estrutura:
#
#			 Iniciando uma classe
#			 $ classe nova_classe
#
#			 Classes reservadas:
#
#			 calendar, general, color, dnd, entry, file, font, form, icons, list, multi_progress,
#			 notebook, notification, print, progress, scale e text_info.
#
#			 As Classes reservadas são inicializadas como somente leitura onde outra classe 
#			 poderá herdar seus métodos e propriedades.
#
#			 Exemplo:
#					classe: color
#					Métodos: color init_color palette extra
#
#			 (classe reservada) (nova classe)
#			 $     color            cor
#
#			 Neste exemplo, foi criado uma nova classe chamada 'cor' do tipo 'color', onde
#			 a nova classe herda os métodos da classe 'color'.
#			 Após a criação da nova classe:
#
#			 cor.color
#			 cor.init_color
#			 cor.palette
#		     cor.extra
#
#			 Atribuir valor a um método:
#			 $ cor.color valor
#
#			 Imprimir o valor armazenado
#			 $ cor.color
#
#			 Carregar a interface
#			 $ cor.show
#				 ou
#			 $ show classe
#
#			 Destruir uma classe
#			 $ cor.del
#                ou
#			   wyad.__del__ classe
#
#
#			Os métodos das classes mantém a nomenclatura dos paramêtros utilizandos pelo comando 'yad' sofrendo
#			apenas uma pequena alteração nos parâmetros longos que contém '-', que são convertidos para '_'.
#			Exemplo:
#				   yad					método
#			--multi-progress -> classe.multi_progress
#			--text-info		 -> classe.text_info
# ----------------------------------------------------------------------------------------------------------

# Verifica se o 'yad' está presente.
[ $(command -v yad) ] || { echo "$(basename "$0"): erro: 'yad' não está instalado." 1>&2; exit 1; }

# Declarando os métodos das classes reservadas.
# Somente leitura
declare -ar __CALENDAR=(day month year details date_format)
declare -ar __GENERAL=(title window_icon width height geometry timeout timeout_indicator text text_align image image_on_top icon_theme expander button no_buttons buttons_layout no_markup borders always_print_result selectable_labels sticky fixed on_top center mouse undecorated skip_taskbar maximized fullscreen plug tabnum kill_parent print_xid image_path)
declare -ar __COLOR=(color init_color palette extra)
declare -ar __DND=(tooltip command)
declare -ar __ENTRY=(entry_label entry_text hide_text completion numeric editable licon licon_action ricon ricon_action)
declare -ar __FILE=(filename multiple directory save separator confirm_overwrite file_filter add_preview quoted_output)
declare -ar __FONT=(fontname preview)
declare -ar __FORM=(field align columns separator item_separator date_format scroll quoted_output)
declare -ar __ICONS=(read_dir compact generic listen item_width term sort_by_name descend single_click)
declare -ar __LIST=(no_headers column checklist radiolist no_click separator multiple editable print_all ellipsize print_column hide_column expand_column search_column tooltip_column limit dclick_action regex_search listen quoted_output)
declare -ar __MULTI_PROGRESS=(bar vertical align auto_close auto_kill)
declare -ar __NOTEBOOK=(key tab tab_pos tab_borders)
declare -ar __NOTIFICATION=(command listen separator item_separator menu no_middle hidden)
declare -ar __PRINT=(filename type headers print_add_preview fontname)
declare -ar __PROGRESS=(progress_text percentage pulsate auto_close auto_kill rtl enable_log log_expanded log_on_top log_height)
declare -ar __SCALE=(value min_value max_value step page print_partial hide_value vertical invert mark)
declare -ar __TEXT=(fore back fontname wrap justify margins tail filename editable show_uri listen)

# Array que irá conter os nomes das classes criadas pelo usuário. Os nomes serão armazenados para
# controlar se uma classe já inicializada e evitando conflitos.
declare -A __HANDLE_CLASS

# Cada classe receberá seu 'ID' que é incrementada a cada criação.
declare -i __CLASSID=1

# Nome das classes reservadas.
declare -ar __WYAD_CLASS=(calendar general color dnd entry file font form icons list multi_progress notebook notification print progress scale text_info)

# Mensagem d erro
err_msg()
{
	local __LINE=${BASH_LINENO[$((${#BASH_LINENO[*]}-2))]}	# Obtem o número da linha onde ocorreu o erro
	local __FUNC=${FUNCNAME[$((${#FUNCNAME[*]}-2))]}		# Obtem o nome da função que gerou o erro.

	# Imprime a mensagem de erro.
	# Se a mensagem de erro não for informada, imprime a mensagem padrão (Erro desconhecido)"
	echo "$(basename "$0"): ${__FUNC:-NULL}: linha ${__LINE:--}: erro: ${1:-Erro desconhecido}" 1>&2
	# Finaliza o script
	exit 1
}

# wyad.__init__ tipo_da_classe nome_da_classe
wyad.__init__()
{
	# Verifica os parâmetros passados na função.
	if [ ! "$1" ]; then
		err_msg "requer o tipo da classe"
	elif [ $(echo ${__WYAD_CLASS[@]} | egrep -w -c $1) -eq 0 ]; then
		err_msg "'$1' tipo da classe inválido."
	elif [ $(echo ${__WYAD_CLASS[@]} | egrep -w -c $2) -eq 1 ]; then
		err_msg "'$1' nome da classe é um tipo reservado."
	elif [ ! "$2" ]; then
		err_msg "requer nome da classe."
	elif [ "$(echo "$2" | tr -d a-zA-Z)" ]; then
		err_msg "'$2' nome da classe inválido."
	elif [ ${__HANDLE_CLASS[$2]} ]; then
		err_msg "'$2' classe já foi inicializada."
	fi

	# Variáveis locais
	local __CLASSNAME="$2"
	# Armazena o tipo da classe convertendo a base para maiúsculo.
	# A conversão é feita para criar uma referenciação ao array que contém os métodos
	# da classse atual.
	local __CLASSTYPE="$(echo "$1" | tr a-z A-Z)"

	# Registra a classe.
	__HANDLE_CLASS[$__CLASSNAME]=true

	# Cria array global com associação por nome.
	declare -gA $__CLASSNAME

	# Define as propriedades da classe.
	eval $__CLASSNAME[ID]=$__CLASSID 		# ID
	eval $__CLASSNAME[TYPE]="$__CLASSTYPE"	# Tipo da classe
	# Converte todos os caracteres '_' do nome da classe em '-', adiciona o prefixo '--'
	# e armazena no indice 'EXEC' da classe.
	# A conversão transforma o nome da classe no paramêtro que será executado pelo yad.
	# Exemplo:
	#		Nome da classe			Convertido
	#		calendar				--calendar
	#		multi_progress			--multi-progress
	#
	# Linha de comando final: yad --calendar ....
	#		
	eval $__CLASSNAME[EXEC]="--${1//_/-}"

	# Incrementa o índice do 'CLASSID'
	((__CLASSID++))
	
}

wyad.__del__()
{
	# Verifica os parâmetros
	if [ ! "$1" ]; then
		err_msg "requer o nome da classe."
	elif [ ! ${__HANDLE_CLASS[$1]} ]; then
		err_msg "'$1' classe não encontrada."
	fi

	# Cria referência com os métodos da classe
	local -n __BYREF=__$(eval echo \${$1[TYPE]})

	# Lê os métodos
	for __METHOD in ${__BYREF[@]} ${__GENERAL[@]} del type id show
	do
		# Destroi os métodos da classe
		unset -f $1.$__METHOD
	done
	
	# Limpa a variável da classe e sua 'HANDLE' 
	unset __HANDLE_CLASS[$1] $1

}

show()
{
	# Verifica se a classe existe.
	[ ${__HANDLE_CLASS[$1]} ] || err_msg "'$1' classe não encontrada."

	# Cria um ponteiro para classe
	local -n __RUNCLASS=$1 
	local __CMD=

	# Lê os índices da variável com excessão do índices que armazenam as propriedades
	for __PARAM in $(echo ${!__RUNCLASS[@]} | sed -r 's/(TYPE|ID|EXEC)//g')
	do
		# Incrementa a variável '__CMD' com o parâmetro e o valor do seu respectivo índice.
		# Exemplo:
		# Ìndice=--text
		# valor=${VAR[--text]}
		# Saida:"--text 'meu texto' "
		__CMD+="$__PARAM ${__RUNCLASS[$__PARAM]} "
	done
	
	# Executa o yad com os parâmetros armazenados na variável da classe
	eval yad ${__RUNCLASS[EXEC]} "$__CMD"
}

calendar()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.day(){ [ "\$1" ] && $__CLASS[--day]="\$1" || echo \${$__CLASS[--day]}; }"
			eval "$__CLASS.month(){ [ "\$1" ] && $__CLASS[--month]="\$1" || echo \${$__CLASS[--month]}; }"
			eval "$__CLASS.year(){ [ "\$1" ] && $__CLASS[--year]="\$1" || echo \${$__CLASS[--year]}; }"
			eval "$__CLASS.date_format(){ [ "\$1" ] && $__CLASS[--date-format]="\$1" || echo \${$__CLASS[--date-format]}; }"
			eval "$__CLASS.details(){ [ "\$1" ] && $__CLASS[--details]="\$1" || echo \${$__CLASS[--details]}; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

color()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.init_color(){ [ "\$1" ] && $__CLASS[--init-color]="\$1" || echo \${$__CLASS[--init-color]}; }"
			eval "$__CLASS.palette(){ [ "\$1" ] && $__CLASS[--palette]="\$1" || echo \${$__CLASS[--palette]}; }"
			eval "$__CLASS.extra(){ [ "\$1" ] && $__CLASS[--extra]="\$1" || echo \${$__CLASS[--extra]}; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

dnd()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.tooltip(){ [[ "\$1" ]] && $__CLASS[--tooltip]=\"'\$1'\" || echo \${$__CLASS[--tooltip]}; }"
			eval "$__CLASS.command(){ [[ "\$1" ]] && $__CLASS[--command]=\"'\$1'\" || echo \${$__CLASS[--command]}; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

entry()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.entry_label(){ [[ "\$1" ]] && $__CLASS[--entry-label]=\"'\$1'\" || echo \${$__CLASS[--entry-label]}; }"
			eval "$__CLASS.entry_text(){ [[ "\$1" ]] && $__CLASS[--entry-text]=\"'\$1'\" || echo \${$__CLASS[--entry-text]}; }"
			eval "$__CLASS.hide_text(){ $__CLASS[--hide-text]=; }"
			eval "$__CLASS.completion(){ $__CLASS[--completion]=; }"
			eval "$__CLASS.numeric(){ $__CLASS[--numeric]=; }"
			eval "$__CLASS.editable(){ $__CLASS[--editable]=; }"
			eval "$__CLASS.licon(){ [[ "\$1" ]] && $__CLASS[--licon]=\"'\$1'\" || echo \${$__CLASS[--licon]}; }"
			eval "$__CLASS.licon_action(){ [[ "\$1" ]] && $__CLASS[--licon-action]=\"'\$1'\" || echo \${$__CLASS[--licon-action]}; }"
			eval "$__CLASS.ricon(){ [[ "\$1" ]] && $__CLASS[--ricon]=\"'\$1'\" || echo \${$__CLASS[--ricon]}; }"
			eval "$__CLASS.ricon_action(){ [[ "\$1" ]] && $__CLASS[--ricon-action]=\"'\$1'\" || echo \${$__CLASS[--ricon-action]}; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
}

file()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.filename(){ [[ "\$1" ]] && $__CLASS[--filename]=\"'\$1'\" || echo \${$__CLASS[--filename]}; }"
			eval "$__CLASS.multiple(){ $__CLASS[--multiple]=; }"
			eval "$__CLASS.directory(){ $__CLASS[--directory]=; }"
			eval "$__CLASS.save(){ $__CLASS[--save]=; }"
			eval "$__CLASS.separator(){ [[ "\$1" ]] && $__CLASS[--separator]=\"'\$1'\" || echo \${$__CLASS[--separator]}; }"
			eval "$__CLASS.confirm_overwrite(){ [[ "\$1" ]] && $__CLASS[--confirm-overwrite]=\"'\$1'\" || echo \${$__CLASS[--confirm-overwrite]}; }"
			eval "$__CLASS.file_filter(){ [[ "\$1" ]] && $__CLASS[--file-filter]=\"'\$1'\" || echo \${$__CLASS[--file-filter]}; }"
			eval "$__CLASS.add_preview(){ $__CLASS[--add-preview]=; }"
			eval "$__CLASS.quoted_output(){ $__CLASS[--quoted-output]=; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

font()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.fontname(){ [[ "\$1" ]] && $__CLASS[--fontname]=\"'\$1'\" || echo \${$__CLASS[--fontname]}; }"
			eval "$__CLASS.preview(){ [[ "\$1" ]] && $__CLASS[--preview]=\"'\$1'\" || echo \${$__CLASS[--preview]}; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi

}

form()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.field(){ [[ \$1 ]] && [[ \${$__CLASS[--field]} ]] && $__CLASS[--field]=\${$__CLASS[--field]:+\${$__CLASS[--field]} --field \"'\$1'\" \"'\$2'\"} || $__CLASS[--field]=\"'\$1' '\$2'\"; }"
			eval "$__CLASS.align(){ [[ "\$1" ]] && $__CLASS[--align]=\"'\$1'\" || echo \${$__CLASS[--align]}; }"
			eval "$__CLASS.columns(){ [[ "\$1" ]] && $__CLASS[--columns]=\"'\$1'\" || echo \${$__CLASS[--columns]}; }"
			eval "$__CLASS.separator(){ [[ "\$1" ]] && $__CLASS[--separator]=\"'\$1'\" || echo \${$__CLASS[--separator]}; }"
			eval "$__CLASS.item_separator(){ [[ "\$1" ]] && $__CLASS[--item-separator]=\"'\$1'\" || echo \${$__CLASS[--item-separator]}; }"
			eval "$__CLASS.date_format(){ [[ "\$1" ]] && $__CLASS[--date-format]=\"'\$1'\" || echo \${$__CLASS[--date-format]}; }"
			eval "$__CLASS.scroll(){ $__CLASS[--scroll]=; }"
			eval "$__CLASS.quoted_output(){ $__CLASS[--quoted-output]=; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

icons()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.read_dir(){ [[ "\$1" ]] && $__CLASS[--read-dir]=\"'\$1'\" || echo \${$__CLASS[--read-dir]}; }"
			eval "$__CLASS.compact(){ $__CLASS[--compact]=; }"
			eval "$__CLASS.generic(){ $__CLASS[--generic]=; }"
			eval "$__CLASS.listen(){ $__CLASS[--listen]=; }"
			eval "$__CLASS.item_width(){ [[ "\$1" ]] && $__CLASS[--item-width]=\"'\$1'\" || echo \${$__CLASS[--item-width]}; }"
			eval "$__CLASS.term(){ [[ "\$1" ]] && $__CLASS[--term]=\"'\$1'\" || echo \${$__CLASS[--term]}; }"
			eval "$__CLASS.sort_by_name(){ $__CLASS[--sort-by-name]=; }"
			eval "$__CLASS.descend(){ $__CLASS[--descend]=; }"
			eval "$__CLASS.single_click(){ $__CLASS[--single-click]=; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

list()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.no_headers(){ $__CLASS[--no-headers]=; }"
			eval "$__CLASS.column(){ [[ \$1 ]] && [[ \${$__CLASS[--column]} ]] && $__CLASS[--column]=\${$__CLASS[--column]:+\${$__CLASS[--column]} --column \"'\$1'\"} || $__CLASS[--column]=\"'\$1'\"; }"
			eval "$__CLASS.checklist(){ $__CLASS[--checklist]=; }"
			eval "$__CLASS.radiolist(){ $__CLASS[--radiolist]=; }"
			eval "$__CLASS.no_click(){ $__CLASS[--no-click]=; }"
			eval "$__CLASS.separator(){ [[ "\$1" ]] && $__CLASS[--separator]=\"'\$1'\" || echo \${$__CLASS[--separator]}; }"
			eval "$__CLASS.multiple(){ $__CLASS[--multiple]=; }"
			eval "$__CLASS.editable(){ $__CLASS[--editable]=; }"
			eval "$__CLASS.print_all(){ $__CLASS[--print-all]=; }"
			eval "$__CLASS.ellipsize(){ [[ "\$1" ]] && $__CLASS[--ellipsize]=\"'\$1'\" || echo \${$__CLASS[--ellipsize]}; }"
			eval "$__CLASS.print_column(){ [[ "\$1" ]] && $__CLASS[--print-column]=\"'\$1'\" || echo \${$__CLASS[--print-column]}; }"
			eval "$__CLASS.hide_column(){ [[ "\$1" ]] && $__CLASS[--hide-column]=\"'\$1'\" || echo \${$__CLASS[--hide-column]}; }"
			eval "$__CLASS.expand_column(){ [[ "\$1" ]] && $__CLASS[--expand-column]=\"'\$1'\" || echo \${$__CLASS[--expand-column]}; }"
			eval "$__CLASS.search_column(){ [[ "\$1" ]] && $__CLASS[--search-column]=\"'\$1'\" || echo \${$__CLASS[--search-column]}; }"
			eval "$__CLASS.tooltip_column(){ [[ "\$1" ]] && $__CLASS[--tooltip-column]=\"'\$1'\" || echo \${$__CLASS[--tooltip-column]}; }"
			eval "$__CLASS.limit(){ [[ "\$1" ]] && $__CLASS[--limit]=\"'\$1'\" || echo \${$__CLASS[--limit]}; }"
			eval "$__CLASS.dclick_action(){ [[ "\$1" ]] && $__CLASS[--dclick-action]=\"'\$1'\" || echo \${$__CLASS[--dclick-action]}; }"
			eval "$__CLASS.regex_search(){ [[ "\$1" ]] && $__CLASS[--regex-search]=\"'\$1'\" || echo \${$__CLASS[--regex-search]}; }"
			eval "$__CLASS.listen(){ $__CLASS[--listen]=; }"
			eval "$__CLASS.quoted_output(){ $__CLASS[--quoted-output]=; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
}

multi_progress()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.bar(){ [[ "\$1" ]] && $__CLASS[--bar]=\"'\$1'\" || echo \${$__CLASS[--bar]}; }"
			eval "$__CLASS.vertical(){ $__CLASS[--vertical]=; }"
			eval "$__CLASS.align(){ [[ "\$1" ]] && $__CLASS[--align]=\"'\$1'\" || echo \${$__CLASS[--align]}; }"
			eval "$__CLASS.auto_close(){ $__CLASS[--auto-close]=; }"
			eval "$__CLASS.auto_kill(){ $__CLASS[--auto-kill]=; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

notebook()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.key(){ [[ "\$1" ]] && $__CLASS[--key]=\"'\$1'\" || echo \${$__CLASS[--key]}; }"
			eval "$__CLASS.tab(){ [[ "\$1" ]] && $__CLASS[--tab]=\"'\$1'\" || echo \${$__CLASS[--tab]}; }"
			eval "$__CLASS.tab_pos(){ [[ "\$1" ]] && $__CLASS[--tab-pos]=\"'\$1'\" || echo \${$__CLASS[--tab-pos]}; }"
			eval "$__CLASS.tab_borders(){ [[ "\$1" ]] && $__CLASS[--tab-borders]=\"'\$1'\" || echo \${$__CLASS[--tab-borders]}; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

notification()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.command(){ [[ "\$1" ]] && $__CLASS[--command]=\"'\$1'\" || echo \${$__CLASS[--command]}; }"
			eval "$__CLASS.listen(){ $__CLASS[--listen]=; }"
			eval "$__CLASS.separator(){ [[ "\$1" ]] && $__CLASS[--separator]=\"'\$1'\" || echo \${$__CLASS[--separator]}; }"
			eval "$__CLASS.item_separator(){ [[ "\$1" ]] && $__CLASS[--item-separator]=\"'\$1'\" || echo \${$__CLASS[--item-separator]}; }"
			eval "$__CLASS.menu(){ [[ "\$1" ]] && $__CLASS[--menu]=\"'\$1'\" || echo \${$__CLASS[--menu]}; }"
			eval "$__CLASS.no_middle(){ $__CLASS[--no-middle]=; }"
			eval "$__CLASS.hidden(){ $__CLASS[--hidden]=; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
}

print()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.filename(){ [[ "\$1" ]] && $__CLASS[--filename]=\"'\$1'\" || echo \${$__CLASS[--filename]}; }"
			eval "$__CLASS.type(){ [[ "\$1" ]] && $__CLASS[--type]=\"'\$1'\" || echo \${$__CLASS[--type]}; }"
			eval "$__CLASS.headers(){ $__CLASS[--headers]=; }"
			eval "$__CLASS.print_add_preview(){ $__CLASS[--print-add-preview]=; }"
			eval "$__CLASS.fontname(){ [[ "\$1" ]] && $__CLASS[--fontname]=\"'\$1'\" || echo \${$__CLASS[--fontname]}; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
}

progress()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.progress_text(){ [[ "\$1" ]] && $__CLASS[--progress-text]=\"'\$1'\" || echo \${$__CLASS[--progress-text]}; }"
			eval "$__CLASS.percentage(){ [[ "\$1" ]] && $__CLASS[--percentage]=\"'\$1'\" || echo \${$__CLASS[--percentage]}; }"
			eval "$__CLASS.pulsate(){ $__CLASS[--pulsate]=; }"
			eval "$__CLASS.auto_close(){ $__CLASS[--auto-close]=; }"
			eval "$__CLASS.auto_kill(){ $__CLASS[--auto-kill]=; }"
			eval "$__CLASS.rtl(){ $__CLASS[--rtl]=; }"
			eval "$__CLASS.enable_log(){ [[ "\$1" ]] && $__CLASS[--enable-log]=\"'\$1'\" || echo \${$__CLASS[--enable-log]}; }"
			eval "$__CLASS.log_expanded(){ $__CLASS[--log-expanded]=; }"
			eval "$__CLASS.log_on_top(){ $__CLASS[--log-on-top]=; }"
			eval "$__CLASS.log_height(){ $__CLASS[--log-height]=; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
}

scale()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.value(){ [[ "\$1" ]] && $__CLASS[--value]=\"'\$1'\" || echo \${$__CLASS[--value]}; }"
			eval "$__CLASS.min_value(){ [[ "\$1" ]] && $__CLASS[--min-value]=\"'\$1'\" || echo \${$__CLASS[--min-value]}; }"
			eval "$__CLASS.max_value(){ [[ "\$1" ]] && $__CLASS[--max-value]=\"'\$1'\" || echo \${$__CLASS[--max-value]}; }"
			eval "$__CLASS.step(){ [[ "\$1" ]] && $__CLASS[--step]=\"'\$1'\" || echo \${$__CLASS[--step]}; }"
			eval "$__CLASS.page(){ [[ "\$1" ]] && $__CLASS[--page]=\"'\$1'\" || echo \${$__CLASS[--page]}; }"
			eval "$__CLASS.print_partial(){ $__CLASS[--print-partial]=; }"
			eval "$__CLASS.hide_value(){ $__CLASS[--hide-value]=; }"
			eval "$__CLASS.vertical(){ $__CLASS[--vertical]=; }"
			eval "$__CLASS.invert(){ $__CLASS[--invert]=; }"
			eval "$__CLASS.mark(){ [[ "\$1" ]] && $__CLASS[--mark]=\"'\$1'\" || echo \${$__CLASS[--mark]}; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

text_info()
{
	# Se algum nome de classe foi passado como parâmetro.
	if [ $# -gt 0 ]; then
		# Lê os parâmetros
		for __CLASS in $@
		do
			# Inicia a classe 
			wyad.__init__ $FUNCNAME $__CLASS

			# Herança
			general $__CLASS

			# Registra os mêtodos da classe
			eval "$__CLASS.fore(){ [[ "\$1" ]] && $__CLASS[--fore]=\"'\$1'\" || echo \${$__CLASS[--fore]}; }"
			eval "$__CLASS.back(){ [[ "\$1" ]] && $__CLASS[--back]=\"'\$1'\" || echo \${$__CLASS[--back]}; }"
			eval "$__CLASS.fontname(){ [[ "\$1" ]] && $__CLASS[--fontname]=\"'\$1'\" || echo \${$__CLASS[--fontname]}; }"
			eval "$__CLASS.wrap(){ $__CLASS[--wrap]=; }"
			eval "$__CLASS.justify(){ [[ "\$1" ]] && $__CLASS[--justify]=\"'\$1'\" || echo \${$__CLASS[--justify]}; }"
			eval "$__CLASS.margins(){ [[ "\$1" ]] && $__CLASS[--margins]=\"'\$1'\" || echo \${$__CLASS[--margins]}; }"
			eval "$__CLASS.tail(){ $__CLASS[--tail]=; }"
			eval "$__CLASS.filename(){ [[ "\$1" ]] && $__CLASS[--filename]=\"'\$1'\" || echo \${$__CLASS[--filename]}; }"
			eval "$__CLASS.editable(){ $__CLASS[--editable]=; }"
			eval "$__CLASS.show_uri(){ $__CLASS[--show-uri]=; }"
			eval "$__CLASS.listen(){ $__CLASS[--listen]=; }"
			eval "$__CLASS.del(){ wyad.__del__ $__CLASS; }"
			eval "$__CLASS.type(){ echo \${$__CLASS[TYPE]}; }"
			eval "$__CLASS.id(){ echo \${$__CLASS[ID]}; }"
			eval "$__CLASS.show(){ show $__CLASS; }"
		done
	fi
	
}

general()
{
	if [ $# -gt 0 ]; then
		# Os métodos da classe 'general' são herdados por todas as classes criadas.
		# É nessa classe que esta armazenada as principais propriedades das janelas.
		# tais como, posicionamento, dimensão, estilo, orientação e etc.
		eval "$1.title(){ [[ \$1 ]] && $1[--title]=\"'\$1'\" || echo \${$1[--title]}; }"
		eval "$1.window_icon(){ [[ \$1 ]] && $1[--window-icon]=\"'\$1'\" || echo \${$1[--window-icon]}; }"
		eval "$1.width(){ [[ \$1 ]] && $1[--width]=\"'\$1'\" || echo \${$1[--width]}; }"
		eval "$1.height(){ [[ \$1 ]] && $1[--height]=\"'\$1'\" || echo \${$1[--height]}; }"
		eval "$1.geometry(){ [[ \$1 ]] && $1[--geometry]=\"'\$1'\" || echo \${$1[--geometry]}; }"
		eval "$1.timeout(){ [[ \$1 ]] && $1[--timeout]=\"'\$1'\" || echo \${$1[--timeout]}; }"
		eval "$1.timeout_indicator(){ [[ \$1 ]] && $1[--timeout-indicator]=\"'\$1'\" || echo \${$1[--timeout-indicator]}; }"
		eval "$1.text(){ [[ \$1 ]] && $1[--text]=\"'\$1'\" || echo \${$1[--text]}; }"
		eval "$1.text_align(){ [[ \$1 ]] && $1[--text-align]=\"'\$1'\" || echo \${$1[--text-align]}; }"
		eval "$1.image(){ [[ \$1 ]] && $1[--image]=\"'\$1'\" || echo \${$1[--image]}; }"
		eval "$1.image_on_top(){ $1[--image-on-top]=; }"
		eval "$1.icon_theme(){ [[ \$1 ]] && $1[--icon-theme]=\"'\$1'\" || echo \${$1[--icon-theme]}; }"
		eval "$1.expander(){ [[ \$1 ]] && $1[--expander]=\"'\$1'\" || echo \${$1[--expander]}; }"
		eval "$1.button(){ [[ \$1 ]] && [[ \${$1[--button]} ]] && $1[--button]=\${$1[--button]:+\${$1[--button]} --button \"'\$1'\"} || $1[--button]=\"'\$1'\"; }"
		eval "$1.no_buttons(){ $1[--no-buttons]=; }"
		eval "$1.buttons_layout(){ [[ \$1 ]] && $1[--buttons-layout]=\"'\$1'\" || echo \${$1[--buttons-layout]}; }"
		eval "$1.no_markup(){ $1[--no-markup]=; }"
		eval "$1.borders(){ [[ \$1 ]] && $1[--borders]=\"'\$1'\" || echo \${$1[--borders]}; }"
		eval "$1.always_print_result(){ $1[--always-print-result]=; }"
		eval "$1.selectable_labels(){ $1[--selectable-labels]=; }"
		eval "$1.sticky(){ $1[--sticky]=; }"
		eval "$1.fixed(){ $1[--fixed]=; }"
		eval "$1.on_top(){ $1[--on-top]=; }"
		eval "$1.center(){ $1[--center]=; }"
		eval "$1.mouse(){ $1[--mouse]=; }"
		eval "$1.undecorated(){ $1[--undecorated]=; }"
		eval "$1.skip_taskbar(){ $1[--skip-taskbar]=; }"
		eval "$1.maximized(){ $1[--maximized]=; }"
		eval "$1.fullscreen(){ $1[--fullscreen]=; }"
		eval "$1.plug(){ [[ \$1 ]] && $1[--plug]=\"'\$1'\" || echo \${$1[--plug]}; }"
		eval "$1.tabnum(){ [[ \$1 ]] && $1[--tabnum]=\"'\$1'\" || echo \${$1[--tabnum]}; }"
		eval "$1.kill_parent(){ [[ \$1 ]] && $1[--kill-parent]=\"'\$1'\" || echo \${$1[--kill-parent]}; }"
		eval "$1.print_xid(){ $1[--print-xid]=; }"
		eval "$1.image_path(){ [[ \$1 ]] && $1[--image-path]=\"'\$1'\" || echo \${$1[--image-path]}; }"
	fi
}

# Define as funções com permissão de somente leitura.
declare -rf ${__WYAD_CLASS[@]}
#FIM
