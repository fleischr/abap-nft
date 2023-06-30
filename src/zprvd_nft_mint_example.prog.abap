*&---------------------------------------------------------------------*
*& Report zprvd_nft_mint_example
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprvd_nft_mint_example.

PARAMETERS: p_ctrct TYPE zprvd_smartcontract_addr,
            p_nam   TYPE string,
            p_ntwrk TYPE zprvd_nchain_networkid.

DATA: lcl_prvd_api_helper    TYPE REF TO zcl_prvd_api_helper,
      lcl_prvd_vault_helper  TYPE REF TO zcl_prvd_vault_helper,
      lcl_prvd_nchain_helper TYPE REF TO zcl_prvd_nchain_helper,
      r                      TYPE REF TO zif_ajson,
      lif_contract_create    TYPE REF TO zif_ajson,
      lif_contract_exec      TYPE REF TO zif_ajson.

lcl_prvd_api_helper = NEW zcl_prvd_api_helper( ).
lcl_prvd_api_helper->get_vault_helper( IMPORTING eo_prvd_vault_helper = lcl_prvd_vault_helper  ).
lcl_prvd_api_helper->get_nchain_helper( IMPORTING eo_prvd_nchain_helper = lcl_prvd_nchain_helper ).

data: ls_vault type zif_prvd_vault=>ty_vault_query,
      ls_wallet_key type zif_prvd_vault=>ty_vault_keys.

ls_vault = lcl_prvd_vault_helper->get_org_vault(  ).
ls_wallet_key = lcl_prvd_vault_helper->get_wallet_vault_key( ls_vault-id  ).


DATA:  ls_selectedcontract           TYPE zif_prvd_nchain=>ty_chainlinkpricefeed_req,
       lv_contract_id                type zcasesensitive_str.

lcl_prvd_nchain_helper->smartcontract_factory( EXPORTING iv_smartcontractaddress = p_ctrct
                                                         iv_name                 = p_nam
                                                         iv_walletaddress        = ls_wallet_key-id
                                                         iv_nchain_networkid     = p_ntwrk
                                                         iv_contracttype         = 'nft-minter'
                                               IMPORTING es_selectedcontract     = ls_selectedcontract ).
lv_contract_id = lcl_prvd_nchain_helper->create_contract( EXPORTING iv_smartcontractaddr = p_ctrct is_contract = ls_selectedcontract ).

DATA: lt_wallets TYPE zif_prvd_nchain=>ty_account_list,
      ls_wallet  TYPE zif_prvd_nchain=>ty_account.


lcl_prvd_nchain_helper->get_accounts( IMPORTING et_accounts = lt_wallets ).
READ TABLE lt_wallets INDEX 1 INTO ls_wallet.
IF sy-subrc <> 0.
ENDIF.

DATA: tab TYPE string_table.

DATA ls_exec_contract_req TYPE zif_prvd_nchain=>ty_executecontractreq_account.
ls_exec_contract_req-account_id = ls_wallet-id.
ls_exec_contract_req-method = 'openMint'.
ls_exec_contract_req-params = tab.
ls_exec_contract_req-value = 0.

lcl_prvd_nchain_helper->execute_contract( iv_contract_id = lv_contract_id iv_exec_contract_req = ls_exec_contract_req ).
