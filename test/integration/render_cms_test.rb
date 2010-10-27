require File.dirname(__FILE__) + '/../test_helper'

class RenderCmsTest < ActionDispatch::IntegrationTest
  
  def setup
    Rails.application.routes.draw do
      get '/render-implicit'  => 'render_test#implicit'
      get '/render-explicit'  => 'render_test#explicit'
      get '/seed_data_page'   => 'render_test#seed_data_page'
    end
    super
  end
  
  def teardown
    load(File.expand_path('config/routes.rb', Rails.root))
  end
  
  class ::RenderTestController < ApplicationController
    def implicit
      render
    end
    def explicit
      render :cms_page => '/render-explicit-page'
    end
    def seed_data_page
      render :cms_page => '/'
    end
  end
  
  def test_get_with_no_template
    assert_exception_raised ActionView::MissingTemplate do
      get '/render-implicit'
    end
  end
  
  def test_get_with_implicit_cms_template
    page = cms_pages(:child)
    page.slug = 'render-implicit'
    page.save!
    get '/render-implicit'
    assert_response :success
  end
  
  def test_get_with_explicit_cms_template
    page = cms_pages(:child)
    page.slug = 'render-explicit-page'
    page.save!
    get '/render-explicit'
    assert_response :success
  end
  
  def test_get_with_explicit_cms_template_failure
    page = cms_pages(:child)
    page.slug = 'render-explicit-404'
    page.save!
    assert_exception_raised ActionView::MissingTemplate do
      get '/render-explicit'
    end
  end
  
  def test_get_seed_data_page
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    get '/seed_data_page'
    assert_response :success
    assert assigns(:cms_page)
    assert assigns(:cms_page).new_record?
  end
  
end