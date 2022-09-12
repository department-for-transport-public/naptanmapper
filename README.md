# naptanmapper
naptanmapper is an R package, created to allow individuals to see National Public Transport Access Nodes (NaPTAN) data on a map. It utilises the [naptanr package](https://github.com/department-for-transport-public/naptanr) to access live NaPTAN API data, and is filterable both by locality and specific stops. Data for the selection is displayed in a searchable table. This app is written in the R programming language.

The NaPTAN dataset provides the location and type of every location you can join or leave public transport in England, Scotland and Wales. Further details and documentation on NaPTAN can be found [here](https://beta-naptan.dft.gov.uk/), and documenation on the NaPTAN API can be found [here](https://www.api.gov.uk/dft/national-public-transport-access-nodes-naptan-api/#national-public-transport-access-nodes-naptan-api).

## 1 Running the app
### 1.1 R and RStudio
naptanmapper requires an installation of R to run. 

You can install R and RStudio (recommended interface to use), for free, following [this guidance](https://rstudio-education.github.io/hopr/starting.html).

If you do not want to download R, you can also access the tool using RStudio Cloud. RStudio is an integrated development environment for R, and the Cloud version can be accessed [here](https://rstudio.cloud/plans/free) for free.

To set up RStudio Cloud to run this app:
1. Naviagte to [(https://rstudio.cloud/plans/free)](https://rstudio.cloud/plans/free)
2. Click "Sign up"
3. Create an account and verify email
4. Select "New project" > "New RStudio project"

This will open RStudio in your browser. **Make sure you are in the Console** before running the installation code (1.2) and running the app (1.3). 

![image](https://user-images.githubusercontent.com/94065155/189688647-c61990fa-6853-4325-839b-b0f2adc785a5.png)

### 1.2 Installation
You will need to install the package from GitHub before being able to run the app. This tasks only needs to be completed once.

You can install the development version of naptanr from [GitHub](https://github.com/) by pasting the below code into your RStudio console:

``` r
install.packages("remotes")
remotes::install_github("department-for-transport-public/naptanmapper")
```

This will install all dependency packages. This may take a while when you first install the package, especially if you have not installed anything previously. Please be patient as you should only need to do this once.

### 1.3 Loading the app
Once naptanmapper is installed, run the app by pasting the below into your console:

```
naptanmapper::run_naptan_mapper()
```
It should look something like this:

![image](https://user-images.githubusercontent.com/94065155/189182789-0a6832d6-dd73-44ee-9e86-3459331b284c.png)

Run the above line of code every time you want to access the app. It will pull in the most recent data from the API each time it is run.

#### 1.3.1 Possible issues running the app
1. The app may close after some time if left dormant. This is not a problem. Simply re-run the above code line (1.3) to re-boot the app. 
2. Some errors may appear in the console once the app is run. So long as the app continues to function please ignore these; they occur due to breaks in the logiv whilst reactive fatures load and should correct themselves
3. Sometimes, the app will close but the background code will keep running. If you are having problems re-running the app code (1.3), see if the console is running. TO check this, look in the top right corner of the console. If there is a red stp button this means the console is running and will not run any new code. **Simply select the red stop button to stop the console, and run the app code again (1.3).**
![image](https://user-images.githubusercontent.com/94065155/189690058-386c637a-b97d-455a-8b2a-6f3a50096692.png)

## 2 Features
### 2.1 Inputs

Inputs for the tool are on the lefthand side of the app in the sidebar. There are five inputs in total which will change the data displayed in the map and table. 

#### 2.1.1 Local area
The options in this drop down relate to the first three digits of the ATCO code. A reference table for these can be found in the [NPTG and NaPTAN Schema Guide](http://naptan.dft.gov.uk/naptan/schema/2.4/doc/NaPTANSchemaGuide-2.4-v0.57.pdf), section 15.11. This input loads data for this area from the NaPTAN API. Only stops within the selected area will be displayed.

This input is searchable. To search:
- Click the input
- Press backspace
- Start typing your desired area

**N.b. if the characters entered into the search do not exist in the drop down list, this input will jump back to the previous selection and you will need to start your entry again**

#### 2.1.2 Locality or stop
A toggle for whether to present all data for a given locality, or just one specific stop. The value of this input will determine the contents of the next two drop down lists (sections 2.1.3 and 2.1.4). 

#### 2.1.3 Search by
A drop down with the options for which data field to search by. This is either a code or a name. If locality is selected in the above toggle, then the options will be Locality Code or Locality Name. If stop is selected, then the options will be ATCO Code or Stop Name. 

#### 2.1.4 Select variable to display
A drop down containing a list of options for which the map and table will display data. Dependent on the selection in the locality or stop toggle (2.1.2) this will either be all stops within a selected locality, or a single stop.  Data for which is displayed below the map in a table.

This input is searchable. To search:
- Click the input
- Press backspace
- Start typing your desired area

**N.b. if the characters entered into the search do not exist in the drop down list, this input will jump back to the previous selection and you will need to start your entry again**

#### 2.1.5 Clear selected stops
This button will remove the red highlighting from any selected stops fromt he map and table. More information in the below sections (2.2.1 and 2.3).

### 2.2 Map display
The map displays the stop(s) dependent on the inputs selected on an OpenStreetMap background. A rough polygon has been plotted around the outermost stop points for each selection to give a rough indication of locality. The map is interactive and can be zoomed in or out.

#### 2.2.1 Selecting a stop on the map
If you wish to see highlighted information about a stop/set of stops, you can select the markers on the map and the data will be highlighted at the top of the table (2.3). To clear your selection, please use the red "Clear selected stops" button in the sidebar.

### 2.3 Table display
The table will display the data of all stops present on the map. This table is filterable via the input boxes underneath the column headers. The data has not been manipulated, simply loaded in based on selected filters from the NaPTAN API. The table is initially sorted by ATCO Code.

Any stops selected on the map will appear at the top of the table, highlighted red.

## 3 FAQs
### 3.1 How do I see a specific stop on the map?
You will need to know the Area in which the stop belongs (e.g. Cambridgeshire), and the ATCO Code or Stop Name. 
- Select your desired Area in to Local Area input (2.1.1)
- Toggle to Stop (2.1.2)
- Select whether you want to select by ATCO Code or Stop Name (2.1.3)
- Scroll through the Select Variable drop down (2.1.4) for the stop
- **Alternatively** use the search cabability of the drop down to search for a specific stop
- The selected stop will display on the map with its relevant data in the table below

### 3.2 How do I visualise a specific stop within the contet of its locality?
- Follow the steps in 3.1 to locate the stop on the map
- Change the toggle to Locality (2.1.2)
- Dependent in Select Variable input (2.1.3), select the correct locality by name or code (2.1.4)
- The map will display all stops in that locality
- Select the specific stop on the map. You can check this is the correct stop by checcking the now highlighted row
- If the stop is the wrong one, select Clear selected stops (2.1.5) and repeat

Once the correct stop is selected, it will be highlighted red. You can view this in the context of other stops in that locality.

## 4 Suggestions and bugs
If you have any suggestions to improve the naptanmapper app or find any bugs, please add them in the [Issues](https://github.com/department-for-transport/naptan-mapper/issues) section of this GitHub repo. Please include information on your usage needs of the app, how to replicate the bug (if applicable), and requirements for any improvement.

## 5 Contact
If you have any further questions, please contact the NaPTAN inbox: Naptan.NPTG@dft.gov.uk
