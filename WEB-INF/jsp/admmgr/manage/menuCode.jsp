<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator"%>
<%@ taglib prefix="page" uri="http://www.opensymphony.com/sitemesh/page"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 관리자 메뉴
 **************************************************/
%>
<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/themes/default/style.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/jstree.min.js"></script>
    <script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
    <style>
    /* .custom-context-menu{
    	background: #f5f5f5;
    	border: 1px solid #979797;
    	box-shadow: 2px 2px 2px #999999;
    }
    .custom-context-menu li>a{
    	padding: 0 2em 0 2em;
	    width: auto;
	    color: black;
	    line-height: 2.4em;
	    border-radius: 1px;
    } */
    .icon_menu_list .hashtag {
	    display: inline-block; /* 줄바꿈 허용 */
	    max-width: 100px;      /* 원하는 너비 설정 */
	    white-space: normal;   /* 텍스트 줄바꿈 허용 */
	    word-break: break-all; /* 단어가 길 경우 줄바꿈 */
	    line-height: 1;
	}
	#new {
		text-decoration: underline;
	    font-weight: bold;
	    font-size: medium;
	    color: black;
	}
    </style>
    <script type="text/javascript">
    	function fn_ChangeSite(obj){
    		
    		$("div.loader_wrap").show();
    		
    		/* 초기화 */
    		$('#edit')[0].className = 'btn secondary';
			$('.treemenu_tab li').eq(1).hide();
    		createNodes = [];
    		renameNodes = [];
    		deleteNodes = [];
    		sortNodes	= [];
    		
    		
    		var menuRole = "${menuRole}";
    		$("#menuRole").val(menuRole);
    		
    		$('#jstree').jstree("destroy");
    		
    		$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/contsMenuAjax2.do'/>",
				data : {"siteCd":$(obj).val(), "menuRole":$("#menuRole").val()},
				dataType : "text",
				success : function(response){
					var rJson = $.parseJSON(response);
					console.log(rJson);
					console.log(rJson.length);
					
					var data = [];
					
					if(rJson.length > 0) {
						
						// 컨텐츠 제거
						/* rJson = rJson.filter(function(item) {
						    return item.MENU_CD.charAt(0) !== '1';
						}); */
						
						// DEPTH 순으로 정렬 (1뎁스 -> 2뎁스 -> 3뎁스 ...)
						rJson.sort(function(a, b) {
						    return a.DEPTH - b.DEPTH;
						});
						
						
						// 1뎁스
						$.each(rJson, function(key,value){
							
							// 아이콘 처리
							let icon_file_no;
							let icon_file_path;
							let icon_file_type;
							
							if(value.FILE_NO != null) {
								console.log(value.FILE_NO);
								
								icon_file_no = value.FILE_NO;
								
							}
							
							if(value.DEPTH == '1'){
								data.push({ 
									text : value.MENU_NM,
									state : { 'opened': false },
									/* icon : value.ICON != null ? value.ICON : '', */
									icon : value.FILE_NO != null ? '/commonFile/loadIconImage.do?fileNo=' + icon_file_no + '&siteCd=' + $("#siteCd").val() : (value.ICON != (value.ICON == "" ? "" : null) ? value.ICON : 'ico_custom23'),
									site_cd : value.SITE_CD,
									menu_cd : value.MENU_CD,
									p_menu_cd : value.P_MENU_CD,
									menu_tp : value.MENU_TP,
									depth	: value.DEPTH,
									sort_order : value.SORT_ORDER,
									tab_yn : value.TAB_YN,
									url : value.URL,
									rel_url : value.REL_URL,
									open_yn : value.OPEN_YN,
									use_yn : value.USE_YN,
									menu_role : value.MENU_ROLE,
									child_cnt : value.CHILD_CNT,
									children : []
								});
							}
							
						});
						
						// 2,3,4,5뎁스
				        $.each(rJson, function(key, value) {
				            if (value.DEPTH !== '1') {
				            	var parent = findParent(data, value.P_MENU_CD);
				                
				                if (parent) {
				                    parent.children.push({
				                        text: value.MENU_NM,
				                        state: { 'opened': false },
				                        icon: 'ico_default',
				                        site_cd: value.SITE_CD,
				                        menu_cd: value.MENU_CD,
				                        p_menu_cd: value.P_MENU_CD,
				                        menu_tp: value.MENU_TP,
				                        depth: value.DEPTH,
				                        sort_order: value.SORT_ORDER,
				                        tab_yn: value.TAB_YN,
				                        url: value.URL,
				                        rel_url: value.REL_URL,
				                        open_yn: value.OPEN_YN,
				                        use_yn: value.USE_YN,
				                        menu_role: value.MENU_ROLE,
				                        children : []
				                    });
				                }
				            }
				        });
						
					}
					
			        function findParent(data, p_menu_cd) {
			            for (var i = 0; i < data.length; i++) {
			                if (data[i].menu_cd === p_menu_cd) {
			                    return data[i];
			                }
			                // 자식들 속에서 부모를 찾는 경우
			                if (data[i].children && data[i].children.length > 0) {
			                    var parent = findParent(data[i].children, p_menu_cd);
			                    if (parent) {
			                        return parent;
			                    }
			                }
			            }
			            return null; // 부모를 못 찾았을 때
			        }
					
					console.log(data);
					
					$('#jstree').jstree({
                        'core': {
                        	'check_callback': true, // 노드 이동 허용
                        	'data': data,
                        },
                        "contextmenu": {
                            "items": function($node) {
                            	return {
                            		"ccp" : false // 우클릭 기능 불가
                            	}
                                /* return {
                                    "Create": {
                                        "label": "새로만들기",
                                        "action": function() {
                                            var newNode = { "text": "새메뉴"};
                                            $('#jstree').jstree().create_node($node, newNode, "last", function(new_node) {
                                                $('#jstree').jstree('edit', new_node); // 새로 생성된 노드를 편집 모드로
                                            });
                                        }
                                    },
                                    "Rename": {
                                        "label": "이름바꾸기",
                                        "action": function() {
                                            $('#jstree').jstree('edit', $node); // 노드를 편집 모드로 변경
                                        }
                                    },
                                    "Delete": {
                                        "label": "삭제",
                                        "action": function() {
                                            if(confirm("삭제하시겠습니까?")) {
                                                $('#jstree').jstree('delete_node', $node); // 노드 삭제
                                            }
                                        }
                                    }
                                }; */
                            }
                        },
                        "plugins": [/* "dnd",  */"contextmenu", "state", "types"], // 플러그인 설정
					}).on('ready.jstree', function() {
						$('.tx_lft').eq(0).text('');
						$('.tx_lft').eq(1).text('');
						$('input[name="openYn"][value="Y"]').prop('checked', true);
						$('input[name="tabYn"][value="N"]').prop('checked', true);
						$('#menuType').val('');
						$('#url').val('');
						$('#p_sub_url input').val('');
						
						$('.n_table_sty01 tr:last').show();
						$('.btn_n_add').hide();
						
						localStorage.removeItem('jstree');
						
				    }).on('select_node.jstree', function (e, data) {
						console.log(data.node);
		    			fn_click(data.node);
					    
		    			/* url readonly 초기화 */
		    			//$("#url").val($("#preUrl").val());
						$("#url").removeAttr("readonly");
						$("#url").css("background","white");
		    			
					}).on('create_node.jstree', function (e, data) {
						
				        // 모든 노드에 대해 버튼 추가
				        $('#jstree').jstree().get_json('#', { flat: true }).forEach(function (node) {
				            // 만들어지는 노드의 id가 아닐 때만 버튼 추가
				            if (data.node.id !== node.id) {
				                fn_addButtons(node);
				            }
				        });
						
		    			console.log(data.node);
		    			console.log($('#jstree').jstree(true).get_node(data.parent));
		    			
		    			var p_node = $('#jstree').jstree(true).get_node(data.parent);
		    			var siteCd;
						var p_menuCd;
						var menuNm;
						var depth;
						var menuCd;
						
						console.log('p_node');
						console.log(p_node);
						
						// 1depth 메뉴 생성 시
						if(p_node.id === '#') {
							var nodesId = $('#jstree').jstree(true).get_node('#').children;
							
							$.ajax({
								url: "/admmgr/manage/menuCodeMaxNum.do",  // 서버에서 일괄 처리를 위한 URL
		    	                type: "POST",
		    	                data: {"siteCd":$("#siteCd").val(),"p_menuCd":$("#siteCd").val() === "001000000000000" ? "000000000000000" : "100000000000000","depth":"1"},
		    	                success: function(response) {
		    	                	
		    	                	var resp = JSON.parse(response);
		    	                	console.log(resp);
		    	                	console.log(resp[0].menuCd);
		    	                	let existingCreateNode = createNodes.find(node => node.menuCd === resp[0].menuCd);
		    	                	
		    	                	if(existingCreateNode) {
		    	                		// 모든 노드를 수집하여 배열로 변환
		    	    				    var nodes = nodesId.map(function(nodeId) {
		    	    				        var node = $('#jstree').jstree(true).get_node(nodeId);
		    	    				        return node && node.original.menu_cd ? node.original.menu_cd : null;
		    	    				    }).filter(function(menu_cd) {
		    	    				        return menu_cd !== null; // menu_cd가 null이 아닌 값만 필터링
		    	    				    });

		    	    				    // 오름차순 정렬
		    	    				    nodes.sort(function(a, b) {
		    	    				        return a - b; // 숫자 오름차순 정렬
		    	    				    });

		    	    				    // 제일 큰 값 (오름차순에서 마지막 값)
		    	    				    var maxMenuCd = nodes[nodes.length - 1];
		    	    				    
		    	    				    menuCd = fn_makeMenuCd(maxMenuCd, '1');
		    	                	} else {
		    	                		menuCd = resp[0].menuCd;
		    	                	}
		    	                	
		    	                },
		    	                error : function(error){
		    	                	alert(error);
		    	                },
		    	                complete : function(){
		    	                	// 노드의 original에 값을 추가
		    				        data.node.original.site_cd = $('#siteCd').val();
		    				        data.node.original.menu_cd = menuCd;
		    				        data.node.original.p_menu_cd = $("#siteCd").val() === "001000000000000" ? "000000000000000" : "100000000000000";
		    				        data.node.original.text = data.node.text;
		    				        data.text = data.node.text;
		    				        data.node.original.depth = 1;
		    				        /* data.node.original.icon = 'ico_custom23';
		    				        data.node.icon = 'ico_custom23'; */
		    				        data.node.original.menu_role = $('#menuRole').val();
		    				        
		    				        createNodes.push({
		    				            nodeId: data.node.id,
		    				        	siteCd: data.node.original.site_cd,
		    				            p_menuCd: data.node.original.p_menu_cd,
		    				            menuCd: data.node.original.menu_cd,
		    				            menuNm: data.text,
		    				            depth: data.node.original.depth,
		    				            menu_role : data.node.original.menu_role
		    				        });
		    						
		    				     	// 메뉴 전체 선택 취소
		    		    		    $('#jstree').jstree("deselect_all");
		    		    			// 선택 되게끔 처리
		    					    $('#jstree').jstree('select_node', data.node.id);
		    		    			
		    				        fn_click(data.node);
		    	                }
							});
							
							return false;
						}
						
						if(p_node.original.depth >= 5) {
							alert('더 이상 만들 수 없습니다.');
							
							// 새로 생성된 노드를 삭제하여 노드 생성을 취소
					        $('#jstree').jstree(true).delete_node(data.node);
							
							deleteNodes = deleteNodes.filter(node => node.nodeId != data.node.id);
							
							return false;
						}
						
						var children = p_node.children;
						
						console.log('children');
					    console.log(children);
						
					    $('#jstree').jstree('select_node', children.id);
					    
					    if (children.length === 1) {
					        // 자식이 하나일 때의 기본 로직
					        var p_code = p_node.original.menu_cd;
					        var depth = parseInt(p_node.original.depth) + 1;

					        console.log('p_code');
					        console.log(p_code);
					        console.log('depth');
					        console.log(depth);

					        let code = fn_makeMenuCd(p_code, depth);

					        console.log('new code');
					        console.log(code);

					        // 노드의 original에 값을 추가
					        data.node.original.site_cd = p_node.original.site_cd;
					        data.node.original.menu_cd = code;
					        data.node.original.p_menu_cd = p_node.original.menu_cd;
					        data.node.original.text = data.node.text;
					        data.text = data.node.text;
					        data.node.original.depth = parseInt(p_node.original.depth) + 1;
					        data.node.original.menu_role = $('#menuRole').val();

					        createNodes.push({
					        	nodeId: data.node.id,
					        	siteCd: data.node.original.site_cd,
					            p_menuCd: data.node.original.p_menu_cd,
					            menuCd: data.node.original.menu_cd,
					            menuNm: data.text,
					            depth: data.node.original.depth,
					            menu_role : data.node.original.menu_role
					        });
					    } else if (children.length > 1) {
					        // menuCd값이 가장 큰 자식 노드 찾기
					        var secondLastChildNode = children
						        .map(childId => $('#jstree').jstree(true).get_node(childId)) // 각 자식 노드를 가져옴
						        .reduce((maxNode, node) => {
						            return parseInt(node.original.menu_cd, 10) > parseInt(maxNode.original.menu_cd, 10) ? node : maxNode;
						        });

					        console.log('secondLastChildNode');
					        console.log(secondLastChildNode);

					        if (secondLastChildNode) {
					            // 마지막 이전 자식의 menuCd 값을 사용해 새로운 menuCd 생성
					            let p_code = secondLastChildNode.original.menu_cd;
					            let depth = parseInt(secondLastChildNode.original.depth);
					            let newMenuCd = fn_makeMenuCd(p_code, depth);

					            console.log('newMenuCd');
					            console.log(newMenuCd);

					            // 노드의 original에 새로운 menu_cd를 적용
					            data.node.original.site_cd = p_node.original.site_cd;
					            data.node.original.menu_cd = newMenuCd;
					            data.node.original.p_menu_cd = p_node.original.menu_cd;
					            data.node.original.text = data.node.text;
					            data.text = data.node.text;
					            data.node.original.depth = parseInt(p_node.original.depth) + 1;
					            data.node.original.menu_role = $('#menuRole').val();

					            createNodes.push({
					            	nodeId: data.node.id,
					            	siteCd: data.node.original.site_cd,
					                p_menuCd: data.node.original.p_menu_cd,
					                menuCd: data.node.original.menu_cd,
					                menuNm: data.text,
					                depth: data.node.original.depth,
					                menu_role: data.node.original.menu_role
					            });
					        }
					    }
					    
					}).on('rename_node.jstree', function (e, data) {
					    fn_addButtons(data.node);
					    
					    console.log(data);
		    			var siteCd = data.node.original.site_cd;
		    			var menuCd = data.node.original.menu_cd;
		    			var menuNm = data.text; // 변경된 이름
		    	        var maxLength = 50; // 최대 글자 수

		    			// 메뉴 전체 선택 취소
		    		    $('#jstree').jstree("deselect_all");
		    			// 선택 되게끔 처리
					    $('#jstree').jstree('select_node', data.node.id);
		    			
		    			
					    if (menuNm.length > maxLength) {
		    	            alert("이름은 " + maxLength + "글자 이하로 입력해주세요.");
		    	            // 이전 이름으로 되돌림
		    	            $('#jstree').jstree('rename_node', data.node, data.old);
		    	            return;
		    	        }
		    			
		    			// 이미 수정된 노드가 rename배열에 있는지 확인
		    		    let existingRenameNode = renameNodes.find(node => node.menuCd === menuCd);
		    		    
		    		    if (existingRenameNode) {
		    		        existingRenameNode.menuNm = menuNm;  // 이미 있는 노드는 이름만 업데이트
		    		    } else {
		    		        renameNodes.push({ siteCd: siteCd, menuCd: menuCd, menuNm: menuNm });  // 새로운 노드 추가
		    		    }
		    		    
		    		 	// createNodes 배열에서 menuCode가 일치하는 노드를 찾아 이름을 변경
		    		    let existingCreateNode = createNodes.find(node => node.menuCd === menuCd);
		    		 	
		    		    if (existingCreateNode) {
		    		        existingCreateNode.menuNm = menuNm;  // createNodes 배열에서도 이름 업데이트
		    		        
		    		    	 // 이름이 변경된 노드가 createNodes에 있을 경우 renameNodes에서 삭제
		    		        renameNodes = renameNodes.filter(node => node.menuCd !== menuCd);
		    		    }
		    		    console.log(data.node);
		    		    fn_click(data.node);
					    
					}).on('delete_node.jstree', function (e, data) {
						
						setTimeout(function() {
					        // 모든 노드에 대해 버튼을 추가하는 대신, 실제 DOM에 남아 있는 노드에만 추가
					        $('#jstree').jstree().get_json('#', { flat: true }).forEach(function (node) {
					            // 남아 있는 노드에 대해 버튼 추가
					            fn_addButtons(node);
					        });
					    }, 50);
						

		    			console.log(data);
		    			var nodeId = data.node.id;
		    			var siteCd = data.node.original.site_cd;
		    			var menuCd = data.node.original.menu_cd;
		    			var p_menuCd = data.node.original.p_menu_cd;
		    			
		    			console.log(menuCd);
		    			
		    			// 자식 노드가 있는지 확인하고 각 자식 노드에 대해 처리
		    		    var children = data.node.children_d;
		    			
		    		    // 자식 노드의 menuCd를 배열로 저장
		    		    var childMenuCds = [];
		    		    
		    		    if (children && children.length > 0) {
		    		        children.forEach(function(childId) {
		    		            var childNode = $('#jstree').jstree(true).get_node(childId);
		    		            if (childNode) {
		    		                childMenuCds.push(childNode.original.menu_cd);
		    		            }
		    		        });
		    		    }
		    		    
		    		 	// 이미 수정된 노드가 배열에 있는지 확인
		    		    let existingNode = deleteNodes.find(node => node.menuCd === menuCd);
		    		    
		    		 	// createNodes에 해당 노드가 없는 경우에만 deleteNodes에 추가
		    		    if (!createNodes.some(node => node.menuCd === menuCd)) {
		    		        if (existingNode) {
		    		            existingNode.menuCd = menuCd;  // 이미 있는 노드는 이름만 업데이트
		    		        } else {
		    		            deleteNodes.push({ nodeId: nodeId, siteCd: siteCd, menuCd: menuCd, depth: data.node.original.depth });  // 새로운 노드 추가
		    		        }
		    		    }
		    		 	
		    		 	// 삭제된 노드의 menuCd가 createNodes 안에 있는지 확인
		    		    if (createNodes.some(node => node.menuCd === data.node.original.menu_cd)) {
			    		    // 1depth 노드들 menuCd 변경
			    		    if (data.node.original.depth === 1) {
			    		        // jstree의 모든 1depth 노드를 가져옴
			    		        var firstDepthNodes = $('#jstree').jstree(true).get_json('#', { flat: true }).filter(function(node) {
			    		            return node.parent === "#"; // 1depth 노드만 필터링
			    		        });
			    		        
			    		        firstDepthNodes.forEach(function(node) {
			    		            // 각 노드에 대해 다시 get_node로 original 객체를 얻음
			    		            var fullNode = $('#jstree').jstree(true).get_node(node.id);
			
			    		            // 2. 해당 노드의 menuCd가 삭제된 menuCd보다 큰 경우
			    		            if (fullNode.original && fullNode.original.menu_cd > menuCd) {
			    		                // 3. 3자리 숫자를 감소시킴 (ex: '012' -> '011')
			    		                var prefix = fullNode.original.menu_cd.slice(0, 3);
			    		                var newPrefix = (parseInt(prefix, 10) - 1).toString().padStart(3, '0');
			    		                
			    		                // 4. 새로운 menuCd로 변경 (앞 3자리만 -1 적용)
			    		                var newMenuCd = newPrefix + fullNode.original.menu_cd.slice(3);
			    		                
			    		                // 5. jstree의 해당 노드 menuCd 업데이트
			    		                fullNode.original.menu_cd = newMenuCd;
			    		                $('#jstree').jstree(true).rename_node(fullNode, fullNode.text); // 트리에서 이름 갱신
			    		                
			    		             	// 6. 하위 depth 노드들도 menuCd 앞 3자리를 동일하게 변경
			    		                updateChildNodesMenuCd(fullNode, newPrefix);
			    		            }
			    		        });
			
			    		    }
		    		    }
		    		    
		    		 	
		    		 	// sortNodes에서도 노드를 제거
		    		    sortNodes = sortNodes.filter(node => node.menuCd !== menuCd);
		    		 	// sortNodes에서도 자식 노드를 제거
		    		    sortNodes = sortNodes.filter(node => !childMenuCds.includes(node.menuCd));
		    		    
		    		 	// 현재 부모의 모든 자식 노드를 sortNodes에서 찾기
		    		    var siblings = sortNodes.filter(node => node.p_menuCd === p_menuCd);
		    		    // sortOrder 재설정
		    		    siblings.forEach((sibling, index) => {
		    		        sibling.sortOrder = index + 1; // 1부터 시작하는 순서로 설정
		    		    });
		    		 	
		    		 	/* // 부모를 기준으로 그룹화
		    		    let groupedByParent = {};
						
		    		    // sortNodes를 순회하면서 부모를 기준으로 그룹화
		    		    sortNodes.forEach(node => {
		    		        let parentKey = node.p_menuCd || 'root'; // 부모가 없으면 'root'로 그룹화
		    		        if (!groupedByParent[parentKey]) {
		    		            groupedByParent[parentKey] = [];
		    		        }
		    		        groupedByParent[parentKey].push(node);
		    		    });

		    		    // 각 그룹에 대해 sortOrder 재설정
		    		    Object.values(groupedByParent).forEach(group => {
		    		        group.forEach((node, index) => {
		    		            node.sortOrder = index + 1; // 1부터 시작하는 순서로 설정
		    		        });
		    		    }); */
		    		 	
		    		    
		    		 	
		    		 	// createNodes에서 삭제된 노드를 제거
		    		    createNodes = createNodes.filter(node => node.menuCd != menuCd);
		    		 	// createNodes에서도 자식 노드를 제거
		    		    createNodes = createNodes.filter(node => !childMenuCds.includes(node.menuCd));
		    		 	// deleteNodes에서도 자식 노드를 제거
		    		    deleteNodes = deleteNodes.filter(node => !childMenuCds.includes(node.menuCd));
		    		 	
		    		 	// 메뉴 전체 선택 취소
		    		    $('#jstree').jstree("deselect_all");
		    		 	
		    		    $('.tx_lft').eq(0).text('');
						$('.tx_lft').eq(1).text('');
						$('input[name="openYn"][value="Y"]').prop('checked', true);
						$('input[name="tabYn"][value="N"]').prop('checked', true);
						$('#menuType').val('');
						$('#url').val('');
						$('#p_sub_url input').val('');
						
						$('.n_table_sty01 tr:last').show();
						$('.btn_n_add').hide();
						
					}).on('move_node.jstree', function (e, data) {
						
						$('#jstree').jstree().get_json('#', { flat: true }).forEach(function (node) {
					        fn_addButtons(node); // 모든 노드에 대해 버튼 추가
					    });
						
						var parentId = $('#jstree').jstree().get_parent(data.node.id);
						var children = $('#jstree').jstree().get_children_dom(parentId);
						console.log(children);
						
						/* sort_order */
						$.each(children, function(index, value){
							console.log(value.id);
							var childrenId = value.id;
							
							var node = $('#jstree').jstree(true).get_node(childrenId);
							var menuCd = node.original.menu_cd;
							
							node.original.sort_order = index + 1;
							
							//console.log(node.original.menu_cd);
							//console.log(node.original.sort_order);
							
							// 이미 수정된 노드가 sort배열에 있는지 확인
			    		    let existingSortNode = sortNodes.find(node => node.menuCd === menuCd);
			    		    
			    		    if (existingSortNode) {
			    		    	existingSortNode.sortOrder = index + 1;  // 이미 있는 노드는 sortOrder만 업데이트
			    		    } else {
								sortNodes.push({
									siteCd : $('#siteCd').val(),
									p_menuCd : node.original.p_menu_cd,
									menuCd : node.original.menu_cd,
									sortOrder : node.original.sort_order
								});
			    		    }
							
						});
						
					}).on('open_node.jstree', function (e, data) {
						// 편집모드 일 때
						if ($('#edit')[0].className == 'btn primary' && data.node) {
					        // createNodes에 있는 nodeId 값들을 수집
					        var createdNodeIds = createNodes.map(function (item) {
					            return item.nodeId;
					        });
					
					        // 모든 노드에 대해 버튼 추가
					        $('#jstree').jstree().get_json('#', { flat: true }).forEach(function (node) {
					            // node.id가 createNodes에 있는 nodeId와 동일하지 않을 때만 버튼 추가
					            if (!createdNodeIds.includes(node.id)) {
					                fn_addButtons(node);
					            }
					        });
					    }
					}).on('open_all.jstree', function (e, data) {
						
						// 편집모드 일 때
						if($('#edit')[0].className == 'btn primary') {
							$('#jstree').jstree().get_json('#', { flat: true }).forEach(function (node) {
						        fn_addButtons(node); // 모든 노드에 대해 버튼 추가
						    });
						}
						
					})/* .on('contextmenu.jstree', function (e) {
				        var $node = $('#jstree').jstree(true).get_node(e.target);
				        
				        // 노드가 없는 경우
				        if (!$node || !$node.id) {
				            e.preventDefault(); // 기본 메뉴 방지
				         	// 편집모드 일 때
							if($('#edit')[0].className == 'btn primary') {
					            // 사용자 정의 컨텍스트 메뉴 표시
					            showCustomContextMenu(e.pageX, e.pageY);
							}
				        }
				    }); */
					
					$("div.loader_wrap").hide();
				},
				error : function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
					$("div.bh_on_rev_loader").hide();
				}
    		});
    		
    		
    	}
		
    	// 사용자 정의 컨텍스트 메뉴 표시 함수
    	/* function showCustomContextMenu(x, y) {
    	    // 사용자 정의 메뉴 HTML 생성
    	    var $menu = $('<div class="custom-context-menu" style="position: absolute; z-index: 1000;">\
    	        <ul>\
    	            <li onclick="addNode()">\
    	            	<a href="#" rel="1">새로만들기</a>\
    	            </li>\
    	        </ul>\
    	    </div>');

    	    // 메뉴 위치 설정
    	    $menu.css({
    	        display: 'block',
    	        left: x + 'px',
    	        top: y + 'px'
    	    });
			
    	    if($('.custom-context-menu').length === 0){
	    	    // 메뉴를 body에 추가
	    	    $('body').append($menu);
    	    }

    	    // 메뉴 외부 클릭 시 메뉴 닫기
    	    $(document).on('click', function () {
    	        $menu.remove();
    	    });
    	} */

    	// 노드 추가 함수
    	/* function addNode() {
    	    // 노드 추가 로직
    	    $('#jstree').jstree().create_node('#', { "text": "새 메뉴" }, "last");
    	} */
    	
    	/* 버튼 추가 */
    	function fn_addButtons(node) {
    	    // 노드의 DOM 요소에 접근하여 버튼 추가
    	    var $nodeElement = $('#' + node.id + '_anchor'); // _anchor를 사용하여 jstree의 노드에 접근
    	    var upButton = $('<img src="/common/admmgr/images/icon/ico_outline_up.png" alt="upButton" id="upButton" style="padding-left: 10px;"/>');
    	    var downButton = $('<img src="/common/admmgr/images/icon/ico_outline_down.png" alt="downButton" id="downButton" style="padding-left: 5px;"/>');

    	    // 기존 버튼이 있으면 중복 추가 방지
    	    if ($nodeElement.find('img').length === 0) {
    	        // 버튼을 노드의 끝에 추가
    	        $nodeElement.append(upButton);
    	        $nodeElement.append(downButton);

    	        // 버튼 클릭 이벤트 핸들러
    	        upButton.on('click', function () {
    	            moveNodeUp(node);
    	        });
    	        downButton.on('click', function () {
    	            moveNodeDown(node);
    	        });
    	    }
    	}
    	
    	// 메뉴 위로 이동
    	function moveNodeUp(node) {
    	    var parentNode = $('#jstree').jstree().get_parent(node.id);
    	    var children = $('#jstree').jstree().get_children_dom(parentNode);

    	    // 현재 노드의 인덱스 찾기
    	    var index = children.toArray().indexOf($('#' + node.id)[0]);

    	    if (index > 0) {
    	        var prevNode = $(children[index - 1]);
    	        $('#jstree').jstree().move_node(node.id, prevNode, "before");
    	        fn_addButtons(node);
    	    } else {
    	    	alert("더이상, 상단으로 이동할 수 없습니다.");
    	    }
    	}
		
    	// 메뉴 아래로 이동
    	function moveNodeDown(node) {
    	    var parentNode = $('#jstree').jstree().get_parent(node.id);
    	    var children = $('#jstree').jstree().get_children_dom(parentNode);

    	    // 현재 노드의 인덱스 찾기
    	    var index = children.toArray().indexOf($('#' + node.id)[0]);

    	    if (index < children.length - 1) {
    	        var nextNode = $(children[index + 1]);
    	        $('#jstree').jstree().move_node(node.id, nextNode, "after");
    	        fn_addButtons(node);
    	    } else {
    	    	alert("더이상, 하단으로 이동할 수 없습니다.");
    	    }
    	}

    	
    	// 편집 버튼
    	function fn_editMode(a) {
    		
    		let previousClassNm = '';
    		if(a !== '') {
    			previousClassNm = a.className;
    		}
    		
    		try {
    			
    			// 메뉴가 없을 때
			    if ($('#jstree').jstree(true).get_json('#').length === 0) {
			        // 메뉴 생성 버튼 추가
			        $('.jstree-contextmenu').html('<a href="#" id="new" onclick="fn_firstCreateMenu();"><span>메뉴 생성하기</span></a>');
			    }
    			
    			// 편집모드 활성화
    			if (previousClassNm == 'btn secondary') {
    				a.className = 'btn primary';
    				
    				// 저장 버튼 보이게
    				$('.treemenu_tab li:hidden').first().show();
    				
    				// 트리 메뉴 칸 늘리기
    				//$('.treemenu_lft_area').css('flex', '0 370px');
    				
    				// 위아래 버튼 추가
    				$('#jstree').find('.jstree-node').each(function() {
				        var nodeId = $(this).attr('id');
				        var node = $('#jstree').jstree().get_node(nodeId);
				        fn_addButtons(node);
				    });
    				
    				$('#jstree').jstree(true).settings.contextmenu.items = function ($node) {
    					var depth = $node.original.depth || $node.parents.length;
    					
    					if(depth === 1) {
	    	                return {
	    	                	"CreateRoot": {
	                                "label": "최상위 메뉴 만들기",
	                                "action": function() {
	                                    var newNode = { "text": "새메뉴"};
	                                    $('#jstree').jstree().create_node("#", newNode, "last", function(new_node) {
	                                    	/* new_node.icon = 'ico_custom23'; */
	                                        $('#jstree').jstree('edit', new_node); // 새로 생성된 노드를 편집 모드로
	                                    });
	                                }
	                            },
	    	                	"Create": {
	                                "label": "새로만들기",
	                                "action": function() {
	                                    var newNode = { "text": "새메뉴"};
	                                    $('#jstree').jstree().create_node($node, newNode, "last", function(new_node) {
	                                        $('#jstree').jstree('edit', new_node); // 새로 생성된 노드를 편집 모드로
	                                    });
	                                }
	                            },
	                            "Rename": {
	                                "label": "이름바꾸기",
	                                "action": function() {
	                                    $('#jstree').jstree('edit', $node); // 노드를 편집 모드로 변경
	                                }
	                            },
	                            "Delete": {
	                                "label": "삭제",
	                                "action": function() {
	                                    if(confirm("삭제하시겠습니까?")) {
	                                        $('#jstree').jstree('delete_node', $node); // 노드 삭제
	                                    }
	                                }
	                            }
	    	                }
    					} else {
    						return {
	    	                	"Create": {
	                                "label": "새로만들기",
	                                "action": function() {
	                                    var newNode = { "text": "새메뉴"};
	                                    $('#jstree').jstree().create_node($node, newNode, "last", function(new_node) {
	                                        $('#jstree').jstree('edit', new_node); // 새로 생성된 노드를 편집 모드로
	                                    });
	                                }
	                            },
	                            "Rename": {
	                                "label": "이름바꾸기",
	                                "action": function() {
	                                    $('#jstree').jstree('edit', $node); // 노드를 편집 모드로 변경
	                                }
	                            },
	                            "Delete": {
	                                "label": "삭제",
	                                "action": function() {
	                                    if(confirm("삭제하시겠습니까?")) {
	                                        $('#jstree').jstree('delete_node', $node); // 노드 삭제
	                                    }
	                                }
	                            }
	    	                }
    					}
    	            };
    	            //$('#jstree').jstree(true).refresh();
    	        
    	        // 편집모드 비활성화
    			} else {
    				
    				// 저장버튼 안보이게
    				$('.treemenu_tab li').eq(1).hide();
    				
    				if(a) {
	    				a.className = 'btn secondary';
    				} else {
    					$('#edit')[0].className = 'btn secondary';
    				}
    				
    				//$('.treemenu_lft_area').css('flex', '0 300px');
    				
    				$('#jstree').jstree(true).settings.contextmenu.items = function ($node) {
    	                return {
    	                	"ccp" : false
    	                };
    	            };

    	            $('#jstree').jstree(true).refresh();
    	            
    	            $('#jstree').find('.jstree-node').each(function() {
    	                var nodeId = $(this).attr('id');
    	                var node = $('#jstree').jstree().get_node(nodeId);
    	                $('#' + node.id + '_anchor').find('#upButton, #downButton').remove(); // 버튼 제거
    	            });
    	            
    	         	// 초기화
    	    		createNodes = [];
    	    		renameNodes = [];
    	    		deleteNodes = [];
    	    		sortNodes	= [];
    	            
    			}
    			
    		} catch (error) {
    			alert("오류. " + error);
    			location.reload();
    		}
    		
    	}
    	
    	function fn_firstCreateMenu() {
    		var newNode = { "text": "새메뉴"};
            $('#jstree').jstree().create_node("#", newNode, "last", function(new_node) {
                $('#jstree').jstree('edit', new_node); // 새로 생성된 노드를 편집 모드로
            });
		}
    	
    	let createNodes = []; // create된 노드들을 저장할 배열
    	let renameNodes = []; // rename된 노드들을 저장할 배열
    	let deleteNodes = []; // delete된 노드들을 저장할 배열
    	let sortNodes = []; // sort된 노드들을 저장할 배열
    	
		// 저장 버튼
    	async function fn_save() {
    		try {
    			
    			let createResponse, renameResponse, deleteResponse, sortResponse;
    			
    			if (createNodes.length > 0) {
    	            // AJAX 요청
    	            createResponse = await $.ajax({
    	                url: "/admmgr/manage/menuCodeAppend.do",  // 서버에서 일괄 처리를 위한 URL
    	                type: "POST",
    	                contentType: "application/json",  // JSON 형식으로 데이터를 전송
    	                data: JSON.stringify(createNodes)  // 이름 변경된 노드들을 전송
    	            });

    	            // 응답 처리
    	            if (createResponse.status === "fail") {
    	                alert('create 저장 중 오류가 발생했습니다.');
    	                return false;
    	            }

    	        }

    	        // 이름 변경 노드 처리
    	        if (renameNodes.length > 0) {
    	            renameResponse = await $.ajax({
    	                url: "/admmgr/manage/menuCodeModify.do",  // 서버에서 일괄 처리를 위한 URL
    	                type: "POST",
    	                contentType: "application/json", 
    	                data: JSON.stringify(renameNodes)  
    	            });

    	            // 응답 처리
    	            if (renameResponse.status === "fail") {
    	                alert('rename 저장 중 오류가 발생했습니다.');
    	                return false;
    	            }

    	        }

    	        // 삭제된 노드 처리
    	        if (deleteNodes.length > 0) {
    	            deleteResponse = await $.ajax({
    	                url: "/admmgr/manage/menuCodeRemove.do",
    	                type: "POST",
    	                contentType: "application/json", 
    	                data: JSON.stringify(deleteNodes) 
    	            });

    	         	// 응답 처리
    	            if (deleteResponse.status === "fail") {
    	                alert('delete 저장 중 오류가 발생했습니다.');
    	                return false;
    	            }

    	        }
    	        
    	     	// 삭제된 노드 처리
    	        if (sortNodes.length > 0) {
    	            sortResponse = await $.ajax({
    	                url: "/admmgr/manage/sortOrderMenu.do",
    	                type: "POST",
    	                contentType: "application/json",
    	                data: JSON.stringify(sortNodes)
    	            });

    	         	// 응답 처리
    	            if (sortResponse.status === "fail") {
    	                alert('sort 저장 중 오류가 발생했습니다.');
    	                return false;
    	            }

    	        }
	    		
	    		if(createNodes.length < 1 && renameNodes.length < 1 && deleteNodes.length < 1 && sortNodes.length < 1) {
	    			alert('변경된 내용이 없습니다.');
	    			
	    			// 편집 모드 종료
	    			fn_editMode('');
	    			return false;
	    		}
	    		
	    		// 초기화
	    		createNodes = [];
	    		renameNodes = [];
	    		deleteNodes = [];
	    		sortNodes	= [];
    	        
    	        alert("저장 되었습니다.");
    	        location.reload();
	    		
    		} catch (error) {
    			alert('저장 중 오류가 발생했습니다: ' + error);
    			// 편집 모드 종료
    	        fn_editMode('');
 			}
    	}
    	
    	// 가상의 메뉴코드 만들기
    	function fn_makeMenuCd(p_code, depth) {
    		let codeArr = ["", "", "", "", ""];
	        for (let i = 0; i < 5; i++) {
	            codeArr[i] = p_code.substring(i * 3, (i + 1) * 3);
	        }

	        codeArr[depth - 1] = String(parseInt(codeArr[depth - 1], 10) + 1).padStart(3, '0');
	        let code = codeArr.join("");
	        
	        return code;
    	}
    	
    	// 하위 depth 노드들의 menuCd 앞 3자리를 변경하는 함수
    	function updateChildNodesMenuCd(parentNode, newPrefix) {
    	    var jstreeInstance = $('#jstree').jstree(true);
    	    
    	    // parentNode의 모든 자식 노드를 순회
    	    parentNode.children.forEach(function(childId) {
    	        var childNode = jstreeInstance.get_node(childId);
    	        
    	        if (childNode.original) {
    	            // 하위 노드의 menuCd 앞 3자리를 변경
    	            var updatedMenuCd = newPrefix + childNode.original.menu_cd.slice(3);
    	            childNode.original.menu_cd = updatedMenuCd;
    	         	// 하위 노드의 p_menuCd 앞 3자리를 변경
                    var p_menuCd = newPrefix + childNode.original.p_menu_cd.slice(3);
                    childNode.original.p_menu_cd = p_menuCd;


    	            // jstree의 해당 하위 노드 menuCd 업데이트
    	            jstreeInstance.rename_node(childNode, childNode.text);

    	            // 재귀적으로 더 하위 노드들도 처리
    	            if (childNode.children.length > 0) {
    	                updateChildNodesMenuCd(childNode, newPrefix);
    	            }
    	        }
    	    });
    	}
    	
    	$(document).ready(function(){
    		$("#siteCd").trigger("change");
    		
    		// 등록버튼 hide
		    $('.btn_n_add').hide();
    		
		 	// #jstree 메뉴가 아니면 우클릭 방지
		    $('.zTreeDemoBackground').on('contextmenu', function(e) {
		        if (!$(e.target).closest('#jstree a').length) {
		            e.preventDefault();
		        }
		    });
    		
    	});
    	
    	/* 노드 클릭 시 */
		function fn_click(node){
			if(node !== '') {
				$('#menuCd').val(node.original.menu_cd);
				$('#menuNm').val(node.text);
			}
			
			$("#preUrl").val("");
			
			$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/menuCodeAdminListAjax.do'/>",
				data : {"siteCd":$("#siteCd").val(),"menuCd":$("#menuCd").val() !== "" ? $("#menuCd").val() : "0","menuRole":$("#menuRole").val() != "" ? $("#menuRole").val() : null},
				dataType : "text",
				success : function(data){
					var rJson = $.parseJSON(data);
					
					if( rJson.rList != undefined && rJson.rList != null ){
						if( rJson.rList.length > 0 ){
							var rData = rJson.rList[0];
							
							var menuCode = rData.MENU_CD;
						    var menuName = rData.MENU_NM;
						    var menuRole = rData.MENU_ROLE;
						    var openYn = rData.OPEN_YN;
						    var tabYn = rData.TAB_YN;
						    var regDt = rData.REG_DTM;
						    var mdfDt = rData.MDF_DTM;
						    var menuTp = rData.MENU_TP;
						    var url = rData.URL;
						    var relUrl = rData.REL_URL;
						    var icon = rData.ICON;
						    
						    if(rData.DEPTH == 1) {
						    	$('.n_table_sty01 tr:last').show();
						    } else {
						    	$('.n_table_sty01 tr:last').hide();
						    }
							$('.btn_n_add').show();
						    
						    
							$('.tx_lft').eq(0).text(menuCode);
							$('.tx_lft').eq(1).text(menuName);
							
							if (openYn === 'Y') {
					            $('input[name="openYn"][value="Y"]').prop('checked', true);
					        } else if (openYn === 'N') {
					            $('input[name="openYn"][value="N"]').prop('checked', true);
					        }
							
							if (tabYn === 'Y') {
					            $('input[name="tabYn"][value="Y"]').prop('checked', true);
					        } else if (tabYn === 'N') {
					            $('input[name="tabYn"][value="N"]').prop('checked', true);
					        }
							
							$('.tx_lft').eq(2).text(regDt);
							$('.tx_lft').eq(3).text(mdfDt);
							
							$('#menuType').val(menuTp);
							$('#url').val(url);
							
							if(menuTp === "001001002") {
								$("#url").attr("readonly",true);
								$("#url").css("background","#d6d2d2");
							} else {
								$("#preUrl").val($("#url").val());
								$("#url").val($("#preUrl").val());
								$("#url").removeAttr("readonly");
								$("#url").css("background","white");
							}
							
							// relUrl 초기화
							$('.sub').each(function(){
							    $(this).remove();
							});
							
							if (relUrl) {
							    var relUrlList = relUrl.split(',');
								console.log('relUrlList = ' + relUrlList);
								
							    relUrlList.forEach(function(relUrl, index) {
							    	if(index === 0){
							    		$('#p_sub_url input').val(relUrl);
							    	} else {
							    		$('#p_sub_url').parent().append(
							                    '<p class="sub" style="padding-top:5px;">' +
							                        '<input type="text" class="form_text w90" name="relUrl" value="' + relUrl + '" style="width:calc(100% - 60px);">' +
							                        '<a class="btn scondary xsm" style="min-width:30px;cursor:pointer;" onclick="javascript:fn_DeleteUrl(this);">-</a>' +
							                    '</p>'
							                );
							    	}
							    });
							    
							} else {
								$('#p_sub_url input').val('');
							}
							
							if(icon) {
								$('input[name="iconmenu"][value="' + icon + '"]').prop('checked', true);
							} else {
								$('input[name="iconmenu"][value="ico_custom23"]').prop('checked', true);
							}
							
						} else {
							
							$('.tx_lft').eq(0).text(node.original.menu_cd);
							$('.tx_lft').eq(1).text(node.text);
							$('input[name="openYn"][value="Y"]').prop('checked', true);
							$('input[name="tabYn"][value="N"]').prop('checked', true);
							$('.tx_lft').eq(2).text('');
							$('.tx_lft').eq(3).text('');
							$('#menuType').val('');
							$('#url').val('');
							$('#p_sub_url input').val('');
							
							$('input[name="iconmenu"][value="ico_custom23"]').prop('checked', false);
							
							// 선택된 노드가 1depth가 아닐 때
							if(node.original.depth !== 1){
								$('.n_table_sty01 tr:last').hide();
							} else {
								$('.n_table_sty01 tr:last').show();
							}
							
							// 선택된 노드가 1depth "새메뉴" 일 때
							if(createNodes.find(item => item.menuCd === node.original.menu_cd)) {
								$('.n_table_sty01 tr:last').show();
								$('.btn_n_add').hide();
							} else {
								$('.btn_n_add').show();
							}
							
						}
						
					} else {
						$('input[name="iconmenu"][value="ico_custom23"]').prop('checked', false);
						
						$('.n_table_sty01 tr:last').hide();
						$('.btn_n_add').hide();
					}
					
				},
				error : function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
			
    	}
		
		// 등록 버튼
		function fn_Regist(){
			
			/* 컨텐츠 url 처리 */
			$("#preUrl").val($("#url").val());
			
			var arrRelUrl = new Array();
			$.each($("input[name=relUrl]"),function(idx){
				arrRelUrl.push($(this).val());
			});
			var relUrl = arrRelUrl.toString();
			
			$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/updateMenuAjax.do'/>",
				data : {
					"siteCd":$("#siteCd").val(),
					"menuCd":$("#menuCd").val(),
					"openYn":$("input[name='openYn']:checked").val(),
					"tabYn":$("input[name='tabYn']:checked").val(),
					"menuType":$('#menuType option:selected').val(),
					"url":$("#url").val(),
					"relUrl":relUrl,
					"icon":$('input[name="iconmenu"]:checked').val()
				},
				dataType : "text",
				success : function(data){
					alert("등록 되었습니다.");
					location.reload();
				},
				error : function(request, status, error){
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		
		// 관련  URL + 버튼
		function fn_AddUrl(obj){
			var objP  = $(obj).parent();
			var objTd = $(obj).parent().parent();
			var objClone = $(objP).clone();
			objClone.find("a").attr({
				"class"   : "btn scondary xsm",
				"onclick" : "fn_DeleteUrl(this)"
			}).text("-");
			objClone.css("padding-top","5px");
			objTd.append(objClone);
		}
		// 관련 URL - 버튼
		function fn_DeleteUrl(obj){
			var objP = $(obj).parent();
			objP.remove();
		}
    	
		//메뉴유형 change : 게시판 선택시 게시판 속성 selectbox정의
		function fn_ChangeMenuType(){
			var objSelect = $("#menuType");
			var objP      = objSelect.parent();
			$("#boardMngNo").remove();
			
			if($("#menuCd").val() !== '') {
				//메뉴유형이 컨텐츠일 경우 자동 URL을 매핑한다.
				if( objSelect.val() == "001001002" ){
					$("#url").val("/front/conts/"+$("#menuCd").val()+".do");
					$("#url").attr("readonly",true);
					$("#url").css("background","#d6d2d2");
				} else{
					$("#url").val($("#preUrl").val());
					$("#url").removeAttr("readonly");
					$("#url").css("background","white");
					/* if( objSelect.val() == "001001001000" ){
						$.ajax({
							url     : "<c:url value='/admmgr/manage/menuCodeBoardTypeMngListAjax.do'/>",
							type    : "POST",
							data    : {},
							success : function(data){
								var rData = $.parseJSON(data);
								var strSelect = "";
								strSelect += "<select id='boardMngNo' name='boardMngNo' class='select_type1' style='min-width:350px;' title='게시판 속성 선택'>";
								for( var i=0; i<rData.length; i++ ){
									strSelect += "<option value='"+rData[i].BOARD_MNG_NO+"'>"+rData[i].BOARD_NM+"("+rData[i].BOARD_DC+")</option>";
								}
								strSelect += "</select>";
								objP.append(strSelect);
								$("#boardMngNo").val("<c:out value='${rMap.BOARD_MNG_NO}'/>");
								//관리자인 경우
								if( $("#code").val().substring(0,1) == "0" ){
									$("#url").val("/admmgr/manage/board/List"+$("#boardMngNo").val()+".do");
									$("#url").attr("readonly",true);
									$("#url").css("background","#d6d2d2");
								}else{
									$("#url").val("/front/board/List"+$("#boardMngNo").val()+".do");
									$("#url").attr("readonly",true);
									$("#url").css("background","#d6d2d2");
								}
							}
						});
					} */
				}
			}
		}
	</script>
		
</head>

<body>
	


	<form id="frm" name="frm" method="POST">
		<input type="hidden" id="menuCd" name="menuCd" />
		<input type="hidden" id="menuNm" name="menuNm" />
		<input type="hidden" id="menuRole" name="menuRole" />
		<input type="hidden" id="preUrl" name="preUrl" />
	</form>

	<!--sub_contents_wrap-->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

			<!-- treemenu_con_area -->
			<div class="treemenu_con_area fix">
				<!--로딩 바-->
				<div class="loader_wrap" style="display: none;">
					<div class="loader"></div>
					<p>메뉴정보를 조회중입니다.<br />잠시만 기다려주세요.</p>
				</div>
				<!--/로딩 바-->
				<!-- treemenu_lft_area -->
				<div class="treemenu_lft_area">
					<!-- treemenu_top_area -->
					<div class="treemenu_top_area">
						<select id="siteCd" name="siteCd" class="form_select w100" title="사이트 선택" onChange="javascript:fn_ChangeSite(this);">
							<c:forEach items="${rList}" var="rList" varStatus="status">
								<%-- <c:if test="${rList.SITE_CD ne '001000000000000'}"> --%>
								<option value="<c:out value="${rList.SITE_CD}"/>" ${(param.siteCd eq rList.SITE_CD)?"selected='selected'":""}><c:out value="${rList.SITE_NM}"/></option>
								<%-- </c:if> --%>
							</c:forEach>
						</select>

					</div>
					<!-- // treemenu_top_area -->
					<!-- zTreeDemoBackground -->
					<div class="zTreeDemoBackground left">
						<!-- treemenu_tab -->
						<ul class="treemenu_tab">
							<li class=""><a href="#" class="btn secondary" onclick="fn_editMode(this);" id="edit"><span>편집</span></a></li>
							<li class="" style="display:none;"><a href="#" class="btn primary" onclick="fn_save();"><span>저장</span></a></li>
							<li class=""><a href="#" class="btn secondary" onClick="$('#jstree').jstree('open_all');"><span>펼침</span></a></li>
							<li class=""><a href="#" class="btn secondary" onClick="$('#jstree').jstree('close_all');"><span>닫침</span></a></li>
						</ul>
						<!-- // treemenu_tab -->
						<div id="jstree" style="max-width:300px; min-height: 300px;"></div>

					</div>
					<!-- // zTreeDemoBackground -->
				</div>
				<!-- // treemenu_lft_area -->

				<!-- treemenu_rgt_area -->
				<div class="treemenu_rgt_area">

					<div class="search_list_table">

					<div class="noti_area mt0 mb10">
						<p class="noti_text"><em>메뉴를 새로 생성시 <strong>저장</strong> 버튼을 눌러야 메뉴 정보를 등록 가능합니다.</em></p>
					</div>
					
						<!--리스트 시작-->
						<div class="con_list_wrap">
							<!-- <h6 class="sub_tit_h6 fix"><em>정보 설정</em></h6> -->
							<div class="box_tit">
								<h6 class="title">메뉴 정보 설정</h6>
							</div>
							<div class="n_table_sty01 n_view01">
								<table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
									<colgroup>
										<col width="20%">
										<col width="30%">
										<col width="20%">
										<col width="30%">
									</colgroup>
									<tbody>
										<tr>
											<th>메뉴코드</th>
											<td class="tx_lft"></td>
											<th>메뉴명</th>
											<td class="tx_lft"></td>
										</tr>
										<tr>
											<th>메뉴노출여부</th>
											<td>
												<label class="ch"><input type="radio" name="openYn" value="Y" checked="checked"> Y</label>
												<label class="ch"><input type="radio" name="openYn" value="N"> N</label>
											</td>
											<th>탭메뉴여부</th>
											<td>
												<label class="ch"><input type="radio" name="tabYn" value="Y"> Y</label>
												<label class="ch"><input type="radio" name="tabYn" value="N" checked="checked"> N</label>
											</td>
										</tr>
										<tr>
											<th>등록일</th>
											<td class="tx_lft"></td>
											<th>최종 수정일</th>
											<td class="tx_lft"></td>
										</tr>
										<tr>
											<th>메뉴유형</th>
											<td colspan="3">
												<p id="p_menu_tp">
													<select id="menuType" name="menuType" class="form_select" title="메뉴유형 선택" onchange="fn_ChangeMenuType();" style="width: 37%;">
														<option value="">메뉴유형선택</option>
														<%-- <c:out value="${str:makeCodeSelectBoxForPtCode('001000000000000','001001000','')}" escapeXml='false'/> --%>
													</select>
												</p>
											</td>
										</tr>
										<tr>
											<th>URL</th>
											<td colspan="3">
												<input type="text" class="form_text w90" id="url" name="url" value="">
											</td>
										</tr>
										<tr>
											<th>관련 URL</th>
											<td colspan="3">
												<p id="p_sub_url">
													<input type="text" class="form_text w90" name="relUrl" value="" style="width:calc(100% - 60px);">
													<a id="btn_add_sub_url" class="btn primary xsm" style="min-width:30px;cursor:pointer;" onclick="javascript:fn_AddUrl(this);">+</a>
												</p>
											</td>
										</tr>
										<tr>
											<th>아이콘<a id="btn_add_icon" class="btn scondary xsm" style="min-width:30px;cursor:pointer;" onclick="FrameLayer.open('/admmgr/manage/menuIconLayer.do', 500, 320, 'no', { siteCd: $('#siteCd').val() });">+</a> </th>
											<td colspan="3">
												<ul class="icon_menu_list">
												
													<!-- default 아이콘 -->
													<li style="display: flex; flex-direction: column; justify-content: center;">
														<i class="icon"><img src="/common/admmgr/images/icon/ico_menu23.svg"></i>
														<!-- <span class="hashtag mb5">메뉴23</span> -->
														<label class="ch">
															<input type="radio" name="iconmenu" value="ico_custom23" checked/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu01.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom01"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu02.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom02"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu03.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom03"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu04.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom04"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu05.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom05"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu06.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom06"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu07.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom07"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu08.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom08"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu09.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom09"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu10.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom10"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu11.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom11"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu12.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom12"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu13.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom13"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu14.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom14"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu15.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom15"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu16.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom16"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu17.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom17"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu18.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom18"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu19.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom19"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu20.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom20"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu21.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom21"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu22.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom22"/>
														</label>
													</li>
													<li>
														<label class="ch">
															<i class="icon"><img src="/common/admmgr/images/icon/ico_menu24.svg"></i>
															<input type="radio" name="iconmenu" value="ico_custom24"/>
														</label>
													</li>
													
													<!-- 아이콘 등록한 것 -->
													<c:forEach items="${iList}" var="iList" varStatus="status">
														<c:set var="fileList1" value="${str:makeIconList(iList.FILE_NO, iList.SITE_CD)}"/>
														<li style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
															<i class="icon">
																<img src="<c:url value='/commonFile/loadIconImage.do?fileNo=${fileList1[0].FILE_NO}&siteCd=${fileList1[0].SITE_CD}'/>" alt="<c:out value="${fileList1[0].ORIGIN_NM}"/> 이미지" style="filter: invert(0); width: 32px; height: 32px;"/>
															</i>
															<span class="hashtag mb5"><c:out value="${iList.ICON_NM}"/></span>
															<label class="ch">
																<input type="radio" name="iconmenu" value="${status.count}"/>
															</label>
														</li>
													</c:forEach>
												</ul>
											</td>
										</tr>

									</tbody>
								</table>
							</div>

							<div class="page_btn_wrap jc_between mt20">
								<div class="lft"></div>
								<div class="btn_wrap rgt">
									<a class="btn_n_add" href="javascript:void(0);" onclick="javavscript:fn_Regist();"><span>등록</span></a>
								</div>
							</div>
						</div>

						<!--/리스트 끝-->

					</div>
					<!--// sub_contents_area-->

				</div>
				<!-- // treemenu_rgt_area -->
			</div>
			<!-- // treemenu_con_area -->

		</div>
		<!-- // sub_contents_area -->

	</div>
	<!-- // sub_contents_wrap -->

	   

</body>

