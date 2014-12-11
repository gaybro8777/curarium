require 'spec_helper'

describe ( TrayItemsController ) {
  let ( :tray_item ) { TrayItem.first }
  let ( :tray_dst ) { Tray.find_by_name( 'empty_tray' ) }

  before {
    session[:user_id] = User.first.id
  }

  describe ( 'GET index' ) {
    it {
      get :index
      response.code.should eq( '403' )
    }
  }

  describe ( 'PUT tray_item/move' ) {
    it ( 'should move the item' ) {
      put :move, id: tray_item.id, tray_id: tray_dst.id
      response.code.should eq( '200' )

      tray_item.reload
      tray_item.tray.id.should eq( tray_dst.id )
    }
  }

  describe ( 'POST tray_item/copy' ) {
    let ( :tray_src ) { tray_item.tray }
    let ( :tray_item_count ) { TrayItem.count }

    it ( 'should not modify the original item' ) {
      post :copy, id: tray_item.id, tray_id: tray_dst.id
      response.code.should eq( '200' )

      tray_item.reload
      tray_item.tray.id.should eq( tray_src.id )
    }

    it ( 'should copy the item' ) {
      expect {
        post :copy, id: tray_item.id, tray_id: tray_dst.id
      }.to change( TrayItem, :count ).by( 1 )
    }
  }

}