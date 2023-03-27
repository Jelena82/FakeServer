*** Settings ***
Library    app.py
Library    Process
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections


*** Variables ***
${API_Base_Endpoint}    http://127.0.0.1:5000/api

*** Test Cases ***

#   Task #1: Functional test suite
#   2) Create an automated test suite (using test framework like Robot Framework) that:
#        a) prepares the test environment by starting the http server
#        b) runs test cases per end-point that verify both happy path (sends back a valid json response with the expected values)
#            or edge cases (e.g. id not found)
#        c) shuts down the environment
#        d) prints out the test execution results to the console

Start_Localhost_Server_and Continue_Testing
    Start Server

Test_001_API_Base_Endpoint
    Create Session       API_Testing            ${API_Base_Endpoint}
    ${Get_Response}=     GET On Session         API_Testing             ${API_Base_Endpoint}
    ${json_response}=    set variable           ${Get_Response.json()}
    log to console       ${json_response}
    @{first_name_data}=  get value from json    ${json_response}    people
    ${f_name}=           get from list          ${first_name_data}  0
    should be equal      ${f_name}              ${API_Base_Endpoint}/people
    log to console       ${f_name}==${API_Base_Endpoint}/people
    Delete All Sessions

Test_002_API_People_Endpoint
    Create Session       API_Testing            ${API_Base_Endpoint}/people
    ${Get_Response}=     GET On Session         API_Testing                 ${API_Base_Endpoint}/people
    ${json_response}=    set variable           ${Get_Response.json()}
    @{data}=             get value from json    ${json_response}            results
    ${unpacked_data}=    get from list          ${data}                     0
    ${name}=             get from list          ${unpacked_data}            0
    ${value}=            get from dictionary    ${name}                     name
    should be equal      ${value}               Luke Skywalker
    log to console       ${value}==Luke Skywalker
    Delete All Sessions


Test_003_API_Planets_Endpoint
    Create Session       API_Testing            ${API_Base_Endpoint}/planets
    ${Get_Response}=     GET On Session         API_Testing                 ${API_Base_Endpoint}/planets
    ${json_response}=    set variable           ${Get_Response.json()}
    @{data}=             get value from json    ${json_response}            results
    ${unpacked_data}=    get from list          ${data}                     0
    ${name}=             get from list          ${unpacked_data}            0
    ${value}=            get from dictionary    ${name}                     name
    should be equal      ${value}               Tatooine
    log to console       ${value}==Tatooine
    Delete All Sessions

Test_004_API_Starships_Endpoint
    Create Session       API_Testing            ${API_Base_Endpoint}/starships
    ${Get_Response}=     GET On Session         API_Testing                 ${API_Base_Endpoint}/starships
    ${json_response}=    set variable           ${Get_Response.json()}
    @{data}=             get value from json    ${json_response}            results
    ${unpacked_data}=    get from list          ${data}                     0
    ${name}=             get from list          ${unpacked_data}            0
    ${value}=            get from dictionary    ${name}                     name
    should be equal      ${value}               CR90 corvette
    log to console       ${value}==CR90 corvette
    Delete All Sessions

#   Test_005_API_Edge_Case_Should_Fail
#    Create Session       API_Testing                            ${API_Base_Endpoint}/people/101/
#    ${Get_Response}=     GET On Session      API_Testing        ${API_Base_Endpoint}/people/101/
#    log to console       response= ${Get_Response}
#    Delete All Sessions


#   Task #2: Performance test suite
#       3) Extend the http server to incur a random small delay per http request.

Test_006_API_Send_Delayed_Request
    Create Session       API_Testing            ${API_Base_Endpoint}/delayed_request
    ${Get_Response}=     GET On Session         API_Testing             ${API_Base_Endpoint}/delayed_request
    Should Contain       ${Get_Response.json()['message']}              Delayed response for
    log to console       ${Get_Response.json()['message']}
    Delete All Sessions


#   Task #2: Performance test suite
#     4) Create a performance test suite that:
#        a) prepares the test environment by starting the http server
#        b) accesses one of the end-points continuously for a time duration e.g. 1 minute (sequential access is fine)
#        c) for each access it keeps track of the response time on the client side
#        d) shuts down the environment
#        e) prints out mean & standard deviation of the response time for the end-point

Test_007_API_Endpoint_Response_Time
    Create Session       API_Testing            ${API_Base_Endpoint}/test_people
    ${Get_Response}=     GET On Session         API_Testing                     ${API_Base_Endpoint}/test_people
    log to console    mean_response_time=${Get_Response.json()['mean_response_time']}
    log to console    std_dev_response_time=${Get_Response.json()['std_dev_response_time']}
    Delete All Sessions

#   In Flask, directly terminate a thread is not recommended to do so.
#   However, there is some combination of techniques like cooperative multitasking or concurrency libraries to achieve
#   a similar effect.

Stop_Localhost_Server
    Create Session       API_Testing            ${API_Base_Endpoint}/shutdown
    ${Get_Response}=     GET On Session         API_Testing            ${API_Base_Endpoint}/shutdown
    log to console       ${Get_Response}
    Delete All Sessions
