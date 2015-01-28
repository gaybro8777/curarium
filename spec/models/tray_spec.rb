require 'spec_helper'

describe ( 'Tray model' ) {
  context ( 'with valid data' ) {
    let ( :t ) { Tray.first }

    subject { t }

    it { should be_valid }

    it { should respond_to :name }

    it { should respond_to :owner }

    it { should respond_to :tray_items }

    it { should respond_to :images, :annotations } # through tray_items

    it ( 'should no longer have visualizations attribute' ) {
      should_not respond_to :visualizations
    }

    it ( 'should no longer have specific works attribute' ) {
      should_not respond_to :works
    }

    it {
      t.owner.class.should eq( User )
    }
  }

  describe ( 'tray_items' ) {
    let ( :t ) { Tray.first }

    context ( 'Image' ) {
      it {
        t.images.first.should eq( Image.first )
      }
    }

    context ( 'Annotation' ) {
      it {
        t.annotations.first.should eq( Annotation.first )
      }
    }
  }
}
