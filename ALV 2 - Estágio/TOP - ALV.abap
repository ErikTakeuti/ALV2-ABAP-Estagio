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