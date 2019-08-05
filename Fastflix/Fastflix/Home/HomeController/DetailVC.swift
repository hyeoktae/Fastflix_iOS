//
//  DetailVC.swift
//  Fastflix
//
//  Created by HongWeonpyo on 17/07/2019.
//  Copyright © 2019 hyeoktae kwon. All rights reserved.
//

import UIKit

final class DetailVC: UITableViewController {
  
  var movieId: Int?
  var movieDetailData: MovieDetail?
  
  private let movieTitleLabel: UILabel = {
    let label = UILabel()
//    label.text = "토이스토리"
    label.textColor = .white
    label.font = UIFont.boldSystemFont(ofSize: 18)
    return label
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupDetailInfo()
    setTableView()
    registerTableViewCell()
    
  }
  
  private func setupDetailInfo() {
    //    movieDetailData.
    movieTitleLabel.text = movieDetailData?.name
  
  }
  
  
  override func viewDidLayoutSubviews() {
    tableView.contentInset.top = -view.safeAreaInsets.top
  }
  
  private func registerTableViewCell() {
    tableView.register(DetailViewUpperCell.self, forCellReuseIdentifier: "DetailViewUpperCell")
    tableView.register(DetailViewBelowCell.self, forCellReuseIdentifier: "DetailViewBelowCell")
  }
  
  private func setTableView() {
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.backgroundColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    tableView.showsVerticalScrollIndicator = false
  }
  
  // 테이블뷰 데이터소스
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch indexPath.row {
    case 0 :
      let cell = tableView.dequeueReusableCell(withIdentifier: "DetailViewUpperCell", for: indexPath) as! DetailViewUpperCell
      cell.delegate = self
      
      // 무비아이디전달
      cell.movieId(movieId)
      cell.configureImage(imageURLString: movieDetailData?.verticalImage)
      
      // 나머지 영화정보들 전달하는 데이터 생성 및 전달
      // 남은시간비율(Float)에 대한 계산 공식
      let sliderFloat = Float(0.3455555)
      let remainingTime = String(movieDetailData?.remainingTime ?? 0)
      
      let actor1 = movieDetailData?.actors[0].name ?? ""
      let actor2 = movieDetailData?.actors[1].name ?? ""
      let direc = movieDetailData?.directors[0].name ?? ""
      
      let rate = ageSorting(rate: movieDetailData?.degree.name ?? "")
      
      let actors = "\(actor1), \(actor2)"
      let director = "\(direc)"
      
      // 무비아이디, 이미지 이외의 데이터를 표시하고 있는 디테일뷰의 테이블뷰에 전달
      cell.detailDataSetting(matchRate: movieDetailData?.matchRate, productionDate: movieDetailData?.productionDate, degree: rate, runningTime: movieDetailData?.runningTime, sliderTime: sliderFloat, remainingTime: remainingTime, synopsis: movieDetailData?.synopsis, actors: actors, directors: director)
    
      return cell
      
    case 1 :
      let cell = tableView.dequeueReusableCell(withIdentifier: "DetailViewBelowCell", for: indexPath) as! DetailViewBelowCell
      cell.delegate = self
      
      // 셀에 무비아이디 및 비슷한 콘텐츠의 내용(영화들) 전달
      cell.movieId = self.movieId
      cell.similarMoviesData = movieDetailData!.similarMovies
      
      return cell
      
    default:
      return UITableViewCell()
    }
  }
  
  func ageSorting(rate: String) -> String {
    switch rate {
    case "모든 연령에 해당하는 자가 관람할 수 있는 영화":
      return "전체관람가"
    case "만 12세 이상의 자가 관람할 수 있는 영화":
      return "12"
    case "만 15세 이상의 자가 관람할 수 있는 영화":
      return "15"
    case "청소년은 관람할 수 없는 영화":
      return "청불"
    default:
      return ""
    }
  }

}

// (델리게이트) 플레이버튼 눌렀을때 플레이어 띄우기
extension DetailVC: PlayButtonDelegate {
  func didTapDismissBtn() {
    dismiss(animated: true)
  }
  
  func playButtonDidTap(sender: UIButton) {
    let detailVC = DetailVC()
    present(detailVC, animated: true)
  }
}

// (델리게이트) 디테일뷰 다시 띄우기
extension DetailVC: SimilarMoviesDetailViewCellDelegate {
  func similarMovieDetailViewDidSelectItemAt(movieId: Int) {
    
    APICenter.shared.getDetailData(id: movieId) {
      switch $0 {
      case .success(let movie):
        print("value: ", movie)
        
        let detailVC = DetailVC()
        detailVC.movieId = movie.id
        detailVC.movieDetailData = movie
        
        self.present(detailVC, animated: true)
        
      case .failure(let err):
        print("fail to login, reason: ", err)
        
        let message = """
        죄송합니다. 해당 영화에 대한 정보를 가져오지
        못했습니다. 다시 시도해 주세요.
        """
        
        self.oneAlert(title: "영화데이터 오류", message: message, okButton: "재시도")
      }
    }
  }
}



