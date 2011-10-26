class OZBPersonController < ApplicationController

	@Personas = OZBPerson.paginate(:page => params[:page], :per_page => 30)
  
	# GET /users
  # GET /users.xml
  def index
    @OZBPersonen = OZBPerson.all
		@Personas = OZBPerson.paginate(:page => params[:page], :per_page => 30)

    respond_to do |format|
      format.html #index.html.erb
      format.xml  { render :xml => @OZBPersonen }
    end
  end

	def show
    @person = OZBPerson.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @person = OZBPerson.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /users/1/edit
  def edit
    @person = OZBPerson.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @person = OZBPerson.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to(@person, :notice => 'Person was successfully created.') }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @person = OZBPerson.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @person = OZBPerson.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(OZBPerson_index_url) }
      format.xml  { head :ok }
    end
  end
	
	

end
