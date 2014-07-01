require 'spec_helper'

describe 'visualization requests', :js => true do
  let ( :col ) { Collection.first }

  subject { page }

  shared_examples_for ( 'refine query' ) {
    context ( 'open controls' ) {
      before { 
        execute_script "$( function() { $('.explore_bar').show(); } );"
      }

      it {
        should have_css '.explore_bar #select_property option', text: 'title', visible: false
      }

      it {
        should have_css '.explore_bar #select_property option', text: 'artist', visible: false
      }

      it {
        should have_css '.explore_bar #select_property option', text: 'topics', visible: false
      }

      it {
        should have_css '.explore_bar .filter_bar input#query_term'
      }

      it {
        # should but html button
        should have_css '.explore_bar #exclude_button'
        should have_css '.explore_bar div.exclude', text: 'Exclude'
      }

      it {
        # should but html button
        should have_css '.explore_bar #include_button'
        should have_css '.explore_bar div.include', text: 'Include'
      }

      it {
        should have_css '.explore_bar div.button', text: 'Filter Records'
      }
    }
  }

  describe ( 'get /collections/:id/visualizations' ) {
    describe ( 'thumbnail title' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=thumbnail&property=title"
      }

      it_should_behave_like 'refine query'

      it {
        # thumbnail view currently replaced with spatialc
        #should have_css '.record_thumbnail', count: col.records.count
        should have_css '.item', count: col.records.count
      }

      it {
        # thumbnail view currently replaced with spatialc
        # element id of just a number, not a good plan
        #should have_css ".record_thumbnail[title^='#{col.records.first.id}:']"
        should have_css ".item[id='#{col.records.first.id}']"
      }

      describe ( 'click thumbnail' ) {
        before {
          # thumbnail view currently replaced with spatialc
          #page.execute_script %q[$(".record_thumbnail").first().click();]
          page.execute_script %q[$(".item").first().click();]
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

    describe ( 'simply treemap title' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=title"
      }

      it_should_behave_like 'refine query'

      it {
        # one for each title + one for root node
        should have_css '.node', count: col.records.count + 1
      }

      it {
        should have_css '.node', text: 'Starry Night(1)'
      }

      it {
        should have_css '.node', text: 'Mona Lisa(1)'
      }

      it {
        should have_css '.node', text: 'Last Supper(1)'
      }

      it {
        should have_css '.node', text: 'Lucrezia(1)'
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

      it {
        should have_css '.node', text: 'Da Vinci(2)'
      }

      it {
        should have_css '.node', text: 'Van Gogh(1)'
      }

      it {
        should have_css '.node', text: 'Parmigianino(1)'
      }
    }

    describe ( 'treemap title include one' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=title&include[]=title:Starry Night"
      }

      it {
        should have_css '.node', count: 1 + 1
      }

      it {
        should have_css '.node', text: 'Starry Night(1)'
      }

      it {
        should_not have_css '.node', text: 'Mona Lisa(1)'
      }
    }

    describe ( 'treemap title include two' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=title&include[]=title:Starry Night&include[]=title:Mona Lisa"
      }

      it {
        # no record has two titles (multiple includes require all)
        should have_css '.node', count: 1
      }

      it {
        should_not have_css '.node', text: 'Starry Night(1)'
      }

      it {
        should_not have_css '.node', text: 'Mona Lisa(1)'
      }

      it {
        should_not have_css '.node', text: 'Parmigianino'
      }
    }

    describe ( 'treemap title exclude one' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=title&exclude[]=title:Starry Night"
      }

      it {
        should have_css '.node', count: col.records.count + 1 - 1
      }

      it {
        should_not have_css '.node', text: 'Starry Night(1)'
      }
    }

    describe ( 'treemap title exclude two' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=title&exclude[]=title:Starry Night&exclude[]=title:Mona Lisa"
      }

      it {
        should have_css '.node', count: col.records.count + 1 - 2
      }

      it {
        should_not have_css '.node', text: 'Starry Night(1)'
      }

      it {
        should_not have_css '.node', text: 'Mona Lisa(1)'
      }
    }

    describe ( 'treemap topics' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=topics"
      }

      it {
        # 13 distinct topics in test data
        should have_css '.node', count: 13 + 1
      }

      it {
        should have_css '.node', text: 'Women(3)'
      }

      it ( 'should not screw up values with commas' ) {
        should_not have_css '.node', text: 'Joseph(1)'
        should have_css '.node', text: 'Joseph, Saint(1)'
      }
    }

    describe ( 'treemap topics include one' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=topics&include[]=topics:women"
      }

      it {
        should have_css '.node', count: 10 + 1
      }

      it {
        should have_css '.node', text: 'Women(3)'
      }
    }


    describe ( 'treemap topics include two' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=topics&include[]=topics:women&include[]=topics:portraits"
      }

      it {
        # all topics from only records having both included topics: women & portraits
        should have_css '.node', count: 5 + 1
      }

      it {
        should have_css '.node', text: 'Women(2)'
      }
    }

    describe ( 'treemap topics exclude two' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=topics&exclude[]=topics:Jesus&exclude[]=topics:women"
      }

      it {
        should have_css '.node', count: 3 + 1
      }

      it {
        should_not have_css '.node', text: 'Supper(1)'
      }

      it {
        should_not have_css '.node', text: 'Women'
      }

      it {
        should have_css '.node', text: 'Stars'
      }
    }


    describe ( 'treemap topics exclude one' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=topics&exclude[]=topics:Jesus"
      }

      it {
        should have_css '.node', count: 8 + 1
      }

      it {
        should_not have_css '.node', text: 'Supper(1)'
      }

      it {
        should have_css '.node', text: 'Women(2)'
      }
    }

    describe ( 'treemap click' ) {
      before {
        visit "#{collection_visualizations_path( col )}?type=treemap&property=artist"
        click_link 'parmigianino(1)'
      }

      it {
        should have_css '.node', count: 1 + 1
        should have_css '.node', text: 'Parmigianino(1)'
      }
    }
  }
end
