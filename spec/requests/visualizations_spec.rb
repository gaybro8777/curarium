require 'spec_helper'

describe 'visualization requests', :js => true do
  let ( :col ) { Collection.first }

  subject { page }

  shared_examples_for ( 'refine query' ) {
    it {
      should have_css '#vizualization_property option', text: 'title', visible: false
      should have_css '#vizualization_property option', text: 'artist', visible: false
    }

    it {
      should have_css '#include_property option', text: 'title', visible: false
      should have_css '#include_property option', text: 'artist', visible: false
    }

    it {
      should have_css '#exclude_property option', text: 'title', visible: false
      should have_css '#exclude_property option', text: 'artist', visible: false
    }
  }

  describe ( 'get /collections/:id/visualizations' ) {
    describe ( 'thumbnail title' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=thumbnail&property=title"
      }

      it_should_behave_like 'refine query'

      it {
        should have_css '.record_thumbnail', count: col.records.count
      }

      it {
        should have_css ".record_thumbnail[title^='#{col.records.first.id}:']"
      }

      describe ( 'click thumbnail' ) {
        before {
          page.execute_script %q[$(".record_thumbnail").first().click();]
        }

        it ( 'should show record#show' ) {
          pending "can't headless test new window"
          puts '****'
          puts page.driver.browser.window_handles.size
          puts page.current_url
          puts '****'
          page.current_url.match( '/records' ).should_not eq( nil )
        }
      }
    }

    describe ( 'treemap title' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=title"
      }

      it_should_behave_like 'refine query'

      it {
        # one for each title + one for root node
        should have_css '.node', count: col.records.count + 1
      }
    }

    describe ( 'treemap artist' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=artist"
      }

      it_should_behave_like 'refine query'

      it {
        # there are only 3 artists in test data + 1 for root node
        should have_css '.node', count: 3 + 1
      }
    }
  }
end