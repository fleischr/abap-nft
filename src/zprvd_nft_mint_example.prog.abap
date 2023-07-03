*&---------------------------------------------------------------------*
*& Report zprvd_nft_mint_example
*&---------------------------------------------------------------------*
*& AUTHOR: Ryan Fleischmann, Provide Technologies
*& Test program to demonstrate how to mint NFTs / ERC-721s in SAP ABAP
*& Please see the github for important prerequisite configurations!
*& Github repository: https://github.com/fleischr/abap-nft
*&---------------------------------------------------------------------*
REPORT zprvd_nft_mint_example.

PARAMETERS: p_ctrct TYPE zprvd_smartcontract_addr,
            p_nam   TYPE string,
            p_ntwrk TYPE zprvd_nchain_networkid.

DATA: lcl_prvd_api_helper    TYPE REF TO zcl_prvd_api_helper,
      lcl_prvd_vault_helper  TYPE REF TO zcl_prvd_vault_helper,
      lcl_prvd_nchain_helper TYPE REF TO zcl_prvd_nchain_helper,
      ls_vault               TYPE zif_prvd_vault=>ty_vault_query,
      ls_wallet_key          TYPE zif_prvd_vault=>ty_vault_keys,
      ls_selectedcontract    TYPE zif_prvd_nchain=>ty_chainlinkpricefeed_req,
      lv_contract_id         TYPE zcasesensitive_str,
      lt_accounts            TYPE zif_prvd_nchain=>ty_account_list,
      ls_account             TYPE zif_prvd_nchain=>ty_account,
      tab                    TYPE string_table,
      ls_exec_contract_req   TYPE zif_prvd_nchain=>ty_executecontractreq_account,
      ls_txn_ref             type zif_prvd_nchain=>ty_executecontract_resp,
      ls_txn_details         type zif_prvd_nchain=>ty_basic_txn_details,
      lv_blockexplorer_link  TYPE string,
      lv_txn_id              TYPE string.

"Set up Provide API connectivity. Connect to ident, vault, and nchain for decentralized id, digital wallets, and smart contract integration
lcl_prvd_api_helper = NEW zcl_prvd_api_helper( ).
lcl_prvd_api_helper->get_vault_helper( IMPORTING eo_prvd_vault_helper = lcl_prvd_vault_helper  ).
lcl_prvd_api_helper->get_nchain_helper( IMPORTING eo_prvd_nchain_helper = lcl_prvd_nchain_helper ).

"Retrieve org wallet
ls_vault = lcl_prvd_vault_helper->get_org_vault(  ).
ls_wallet_key = lcl_prvd_vault_helper->get_wallet_vault_key( ls_vault-id  ).

"Setup the smart contract request, include reference to the ABI
lcl_prvd_nchain_helper->smartcontract_factory( EXPORTING iv_smartcontractaddress = p_ctrct
                                                         iv_name                 = p_nam
                                                         iv_walletaddress        = ls_wallet_key-id
                                                         iv_nchain_networkid     = p_ntwrk
                                                         iv_contracttype         = 'nft-minter'
                                               IMPORTING es_selectedcontract     = ls_selectedcontract ).
lv_contract_id = lcl_prvd_nchain_helper->create_contract( EXPORTING iv_smartcontractaddr = p_ctrct is_contract = ls_selectedcontract ).

"Retrieve the account we're using for the selected network
lcl_prvd_nchain_helper->get_accounts( IMPORTING et_accounts = lt_accounts ).
READ TABLE lt_accounts WITH KEY network_id = p_ntwrk INTO ls_account.
IF sy-subrc <> 0.
  MESSAGE 'No account found for selected network' TYPE 'E'.
ENDIF.

"Execute the openMint function of the smart contract to mint a NFT
ls_exec_contract_req-account_id = ls_account-id.
ls_exec_contract_req-method = 'openMint'.
ls_exec_contract_req-params = tab.
ls_exec_contract_req-value = 0.
ls_txn_ref = lcl_prvd_nchain_helper->execute_contract_by_account( iv_contract_id = lv_contract_id iv_exec_contract_req = ls_exec_contract_req ).

"Monitor the transaction. Polygon L2 and Celo layer 1 are fast. Expect mainnet Ethereum and others to be slower!
ls_txn_details = lcl_prvd_nchain_helper->get_tx_details( iv_ref_number = ls_txn_ref-ref ).
lv_txn_id = ls_txn_details-hash.

WRITE: 'Finished NFT mint!'.

CASE p_ntwrk.
  WHEN 'd818afb9-df2f-4e46-963a-f7b6cb7655d2'.
    WRITE: 'See Celo Alfajores block explorer:'.
    lv_blockexplorer_link = |https://alfajores.celoscan.io/tx/|  && lv_txn_id .
    WRITE lv_blockexplorer_link.
  WHEN '4251b6fd-c98d-4017-87a3-d691a77a52a7'.
    WRITE: 'See Polygon Mumbai block explorer:'.
    lv_blockexplorer_link = |https://mumbai.polygonscan.com/tx/|  && lv_txn_id .
    WRITE lv_blockexplorer_link.
  WHEN OTHERS.
    WRITE: 'Use this transaction hash in your block explorer:'.
    WRITE: lv_txn_id.
ENDCASE.
