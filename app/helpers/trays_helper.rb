module TraysHelper
  
  # path to a users or circles
  def x_trays_path( owner )
    if owner.is_a? Circle
      circle_trays_path owner
    else
      user_trays_path owner
    end
  end
  
  
  # path to a user or circle tray
  def x_tray_path( tray )
    if tray.owner_type == 'Circle'
      circle_tray_path tray.owner, tray
    else
      user_tray_path tray.owner, tray
    end
  end
  
  def include_target_class( tray, image_or_annotation_id )
    if tray.tray_items.where( 'image_id = ? OR annotation_id = ?', image_or_annotation_id, image_or_annotation_id ).count > 0
      'item-in'
    end
    'item-out'
  end
  
  def include_class( tray, item_id )
    if tray.tray_items.pluck( :id ).include?( item_id )
      'item-in'
    end
    'item-out'
  end
end
