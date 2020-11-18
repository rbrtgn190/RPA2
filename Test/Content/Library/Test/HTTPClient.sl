namespace: Test
flow:
  name: HTTPClient
  inputs:
    - Password:
        required: false
        sensitive: true
    - UserID:
        required: false
    - Ammount:
        required: false
    - Rate:
        required: false
    - Months:
        required: false
    - excel_file_name: "D:\\\\Demo\\\\RPA\\\\LoansCalculation.xlsx"
    - userID_header: userID
    - pass_header: pass
    - ammount_header: ammount
    - rate_header: rate
    - months_header: months
  workflow:
    - get_cell:
        do:
          io.cloudslang.base.excel.get_cell:
            - excel_file_name: '${excel_file_name}'
            - worksheet_name: LoansCalculation
            - has_header: 'yes'
            - first_row_index: '0'
            - row_index: '0:5'
            - column_index: '0:5'
            - row_delimiter: '|'
            - column_delimiter: ','
            - userID_header: '${userID_header}'
            - pass_header: '${pass_header}'
            - ammount_header: '${ammount_header}'
            - rate_header: '${rate_header}'
            - months_header: '${months_header}'
        publish:
          - data: '${return_result}'
          - header
          - userID_index: '${str(header.split(",").index(userID_header))}'
          - pass_index: '${str(header.split(",").index(pass_header))}'
          - ammount_index: '${str(header.split(",").index(ammount_header))}'
          - rate_index: '${str(header.split(",").index(rate_header))}'
          - months_index: '${str(header.split(",").index(months_header))}'
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: on_failure
    - http_client_post:
        loop:
          for: 'row in data.split("|")'
          do:
            io.cloudslang.base.http.http_client_post:
              - url: 'http://192.168.0.10:9680/vhi-ws/model/BankDemo?wsdl'
              - body: "${'<Envelope xmlns=\"http://schemas.xmlsoap.org/soap/envelope/\">    <Body>        <calcCostLoan xmlns=\"urn:xmlns:attachmate:vhi-ws:BankDemo\">            <calcCostLoanFilters>                <Password>'+row.split(\",\")[int(pass_index)]+'</Password>                <UserId>'+row.split(\",\")[int(userID_index)]+'</UserId>                <AmtToBorrow>'+row.split(\",\")[int(ammount_index)][:-2]+'</AmtToBorrow>                <IntRate>'+row.split(\",\")[int(rate_index)]+'</IntRate>                <NumOfMonths>'+row.split(\",\")[int(months_index)][:-2]+'</NumOfMonths>            </calcCostLoanFilters>        </calcCostLoan>    </Body></Envelope>'}"
          break:
            - FAILURE
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      http_client_post:
        x: 328
        'y': 86
        navigate:
          45ced38d-80b0-24ce-2863-1f8d98e1692e:
            targetId: a788c5e9-f475-194f-e3e1-981ed59bf642
            port: SUCCESS
      get_cell:
        x: 102
        'y': 87
    results:
      SUCCESS:
        a788c5e9-f475-194f-e3e1-981ed59bf642:
          x: 565
          'y': 89
