# ALV2-ABAP-Estagio

### TOP DO ALV

```abap
TABLES: zvendas_02,
        zprodutos_02.

**********************************************************************

TYPE-POOLS: slis. " tipo de pool SLIS que contém as definições necessárias para interagir com as funções ALV

**********************************************************************

TYPES: BEGIN OF vl_vendas,

         venda        TYPE zvendas_02-venda,
         item         TYPE zvendas_02-item,
         produto      TYPE zvendas_02-produto,
         desc_produto TYPE zprodutos_02-desc_produto,
         quantidade   TYPE zvendas_02-quantidade,
         preco        TYPE zvendas_02-preco,
         data         TYPE zvendas_02-data,
         hora         TYPE zvendas_02-hora,

END OF vl_vendas.

**********************************************************************

DATA: gt_saida    TYPE STANDARD TABLE OF vl_vendas,
      ls_saida    LIKE LINE OF gt_saida,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      g_repid     TYPE sy-repid,
      gt_sort     TYPE slis_t_sortinfo_alv.
```

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### TELA DE SELAÇÃO DO ALV

```abap
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: sl_venda FOR  zvendas_02-venda,
                sl_prod  FOR  zvendas_02-produto,
                sl_data  FOR  zvendas_02-data.

SELECTION-SCREEN END OF BLOCK a1.
```

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### F01 - ROTINAS DO ALV

```abap
"Interagir com o front-end - Enviar mensagens
"PV_TEXT - Mensagem
FORM z_sapgui_progress_indicator USING VALUE(pv_text).

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = pv_text.

ENDFORM.

**********************************************************************

"SELEÇÃO DOS DADOS COM O INNER JOIN DA TABELA DE PRODUTO
FORM z_select_data.

  PERFORM z_sapgui_progress_indicator
  USING 'Selecionando dados. Aguarde...'.

  SELECT cv~venda
         cv~item
         cv~produto
         cp~desc_produto
         cv~quantidade
         cv~preco
         cv~data
         cv~hora
    INTO CORRESPONDING FIELDS OF TABLE gt_saida
    FROM  zvendas_02 AS cv
    INNER JOIN zprodutos_02 AS cp ON cp~produto = cv~produto
    WHERE cv~venda IN sl_venda
    AND cv~produto IN sl_prod
    AND cv~data IN sl_data.

ENDFORM.

**********************************************************************

"sub-rotina para impressão da lista
FORM z_list_display.

  PERFORM z_sapgui_progress_indicator
  USING 'Estruturando a lista. Aguarde...'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = g_repid
      it_fieldcat        = gt_fieldcat
      it_sort            = gt_sort
      i_save             = 'A'
    TABLES
      t_outtab           = gt_saida
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************

"PT_FIELDCAT - Tab. com estrutura de linha
"Inicializar estrutura das informações da lista
FORM z_fielcat USING pt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: lf_fieldcat TYPE slis_fieldcat_alv. "a tabela que conterá as configurações dos campos da lista

  CLEAR pt_fieldcat[].

  lf_fieldcat-fieldname = 'VENDA'.
  lf_fieldcat-ref_tabname = 'ZVENDAS_02'. "VENDA
  APPEND lf_fieldcat TO pt_fieldcat.

  lf_fieldcat-fieldname = 'ITEM'.
  lf_fieldcat-ref_tabname = 'ZVENDAS_02'. "ITEM
  APPEND lf_fieldcat TO pt_fieldcat.

  lf_fieldcat-fieldname = 'PRODUTO'.
  lf_fieldcat-ref_tabname = 'ZVENDAS_02'. "PRODUTO
  APPEND lf_fieldcat TO pt_fieldcat.

  lf_fieldcat-fieldname = 'DESC_PRODUTO'.
  lf_fieldcat-ref_tabname = 'ZPRODUTOS_02'. "DESCRIÇÃO DO PRODUTO
  APPEND lf_fieldcat TO pt_fieldcat.

  lf_fieldcat-fieldname = 'QUANTIDADE'.
  lf_fieldcat-ref_tabname = 'ZVENDAS_02'. "QUANTIDADE
  APPEND lf_fieldcat TO pt_fieldcat.

  lf_fieldcat-fieldname = 'PRECO'.
  lf_fieldcat-ref_tabname = 'ZVENDAS_02'. "PREÇO
  lf_fieldcat-do_sum = 'X'.
  APPEND lf_fieldcat TO pt_fieldcat.

  lf_fieldcat-fieldname = 'DATA'.
  lf_fieldcat-ref_tabname = 'ZVENDAS_02'. "DATA
  APPEND lf_fieldcat TO pt_fieldcat.

  lf_fieldcat-fieldname = 'HORA'.
  lf_fieldcat-ref_tabname = 'ZVENDAS_02'. "HORA
  APPEND lf_fieldcat TO pt_fieldcat.

ENDFORM.

**********************************************************************

"Ordenação da lista
"PT_SORT[] - Tabela com informações de ordenação dos campos
FORM z_ordenar_lista USING pt_sort TYPE slis_t_sortinfo_alv.

  DATA: lf_sort TYPE slis_sortinfo_alv.

  CLEAR lf_sort.

  lf_sort-spos = 1. " Sequência de ordenação
  lf_sort-fieldname = 'DATA'. " Nome do campo
  lf_sort-tabname = 'ZVENDAS_02'. " Nome da tabela de lista
  lf_sort-up = 'X'. " Ordenação Crescente
  lf_sort-expa = 'X'. " Expandir lista
  APPEND lf_sort TO gt_sort.

  lf_sort-spos = 2.
  lf_sort-fieldname = 'HORA'.
  lf_sort-tabname = 'ZVENDAS_02'.
  lf_sort-up = 'X'.
  lf_sort-expa = 'X'.
  APPEND lf_sort TO gt_sort.

** Outras opções possíveis de utilização
* lf_sort-down = 'X'. " Ordenação decrescente
* lf_sort-group = '*'. " Mudança de controle: quebra de
* " página, inserir sublinha
* lf_sort-subtot = 'X'. " Subtotal
* lf_sort-comp = 'X'. " Comprimir lista mostrando
* " apenas os subtotais

ENDFORM.
```

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### PROGRAMA PRINCIPAL DO ALV

```abap
REPORT zprog_011_02.

**********************************************************************

INCLUDE ZPROG_011_02_TOP. "VARIÁVEIS GLOBAIS

**********************************************************************

INCLUDE ZPROG_011_02_TELA. "TELA DE SELEÇÃO

**********************************************************************

INCLUDE ZPROG_011_02_F01. "ROTINAS

**********************************************************************

INITIALIZATION.
  g_repid = sy-repid. "evento INITIALIZATION para inicializar algumas variáveis

**********************************************************************

START-OF-SELECTION.

  PERFORM z_select_data. "SELEÇÃO DE DADOS

  PERFORM z_fielcat USING gt_fieldcat. "FIELDCAT

  PERFORM z_ordenar_lista USING gt_sort. "ORDENAR A LISTA

END-OF-SELECTION.

  PERFORM z_list_display. "DISPLAY PARA IMPRIMIR A LISTA
```
