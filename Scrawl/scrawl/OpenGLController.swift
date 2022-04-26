//
//  swift
//  scrawl
//
//  Created by Itghost Fan on 2022/4/18.
//

import UIKit
import GLKit

import SnapKit

enum DrawShape {
    case Triangle
    case Rectangle
    case All
}

class OpenGLController: UIViewController, GLKViewDelegate {
    
    private lazy var triangleVertexSize: GLsizei = 3
    private lazy var rectangleVertexSize: GLsizei = triangleVertexSize * 2
    private lazy var rectangleVertexColumn: GLsizei = 5
    
    private var glkView = GLKView()
    private var triangleEffect = GLKBaseEffect()
    private var rectangleEffect = GLKBaseEffect()
    
    private var drawShape = DrawShape.Rectangle
    
    private var triangleVertexBuffer = UnsafeMutablePointer<GLuint>.allocate(capacity: 1)
    private lazy var triangleVertices = UnsafeMutablePointer<GLKVector3>.allocate(capacity: Int(triangleVertexSize))
    
    private var rectangleVertexBuffer = GLuint()
    private let rectangleVertices: [GLfloat] =      // 注意这里一定要指定类型，不然就不是GLFloat了，无法渲染纹理。
    [
        // bottom right
        0.5, 0.0, 0.0,      1.0, 0.0,
        // top right
        0.5, 0.5, 0.0,      1.0, 1.0,
        // top left
        0.0, 0.5, 0.0,      0.0, 1.0,
        // bottom right
        0.5, 0.0, 0.0,      1.0, 0.0,
        // top left
        0.0, 0.5, 0.0,      0.0, 1.0,
        // bottom left
        0.0, 0.0, 0.0,      0.0, 0.0,
    ]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(glkView)
        glkView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        startOpenGL()
    }
    
    func startOpenGL() {
        glkView.context = EAGLContext(api: .openGLES2)!
        glkView.delegate = self
        EAGLContext.setCurrent(glkView.context)
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        switch drawShape {
        case .Triangle:
            makeTriangle()
            break
        case .Rectangle:
            makeRectangle()
            break
        default:
            makeTriangle()
            makeRectangle()
            break
        }
    }
    
    func makeTriangle() {
        triangleVertices[0].x = -0.5
        triangleVertices[0].y = -0.5
        triangleVertices[0].z = 0.0
        triangleVertices[1].x = 0.0
        triangleVertices[1].y = -0.5
        triangleVertices[1].z = 0.0
        triangleVertices[2].x = -0.5
        triangleVertices[2].y = 0.0
        triangleVertices[2].z = 0.0
        
        triangleEffect.useConstantColor = GLboolean(GL_TRUE)
        triangleEffect.constantColor = GLKVector4(v: (1.0, 1.0, 1.0, 1.0))
        
        glGenBuffers(GLsizei(1), triangleVertexBuffer)
        print("Triangle Buffer \(triangleVertexBuffer[0])")
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), triangleVertexBuffer[0])
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLKVector3>.size) * triangleVertexSize), triangleVertices, GLenum(GL_STATIC_DRAW))
    }
    
    func makeRectangle() {
        rectangleEffect.useConstantColor = GLboolean(GL_TRUE)
        rectangleEffect.constantColor = GLKVector4(v: (1.0, 1.0, 1.0, 1.0))
        
        glGenBuffers(GLsizei(1), &rectangleVertexBuffer)
        print("Rectangle Buffer \(rectangleVertexBuffer)")
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), rectangleVertexBuffer)
        let vertexSize = GLsizei(MemoryLayout<[GLfloat]>.size) * rectangleVertexColumn * rectangleVertexSize
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(vertexSize), rectangleVertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size) * rectangleVertexColumn, UnsafeRawPointer(bitPattern: 0))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), GLint(2), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size) * rectangleVertexColumn, UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 3));
        
        
        let image = UIImage(named: "scrawl")?.cgImage
        do {
            let textureInfo = try GLKTextureLoader.texture(with: image!, options: [GLKTextureLoaderOriginBottomLeft: true, GLKTextureLoaderGrayscaleAsAlpha: true, GLKTextureLoaderApplyPremultiplication: true])
            rectangleEffect.texture2d0.name = textureInfo.name
            rectangleEffect.texture2d0.enabled = GLboolean(GL_TRUE)
            rectangleEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target)!
        } catch {
            print("\(error)")
        }
    }
    
    deinit {
        EAGLContext.setCurrent(nil)
        clearTriangle()
        clearRectangle()
    }
    
    func clearTriangle() {
        if triangleVertexBuffer[0] != 0 {
            glDeleteBuffers(GLsizei(1), triangleVertexBuffer)
        }
        triangleVertices.deallocate()
        triangleVertexBuffer.deallocate()
    }
    
    func clearRectangle() {
        if rectangleVertexBuffer != GLuint(0) {
            glDeleteBuffers(GLsizei(1), &rectangleVertexBuffer)
        }
    }
    
    func drawTraingle() {
        triangleEffect.prepareToDraw()
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(
            GLuint(GLKVertexAttrib.position.rawValue),
            GLint(3),
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<GLKVector3>.size),
            UnsafeRawPointer(nil)
        )
        glDrawArrays(GLenum(GL_TRIANGLES), GLint(0), triangleVertexSize)
    }
    
    func drawRectangle() {
        rectangleEffect.prepareToDraw()
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(
            GLuint(GLKVertexAttrib.position.rawValue),
            GLint(3),
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<GLfloat>.size) * rectangleVertexColumn,
            nil
        )
        glDrawArrays(GLenum(GL_TRIANGLES), GLint(0), rectangleVertexSize)
    }
    
    // MARK: GLKViewDelegate
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        switch drawShape {
        case .Triangle:
            drawTraingle()
            break
        case .Rectangle:
            drawRectangle()
            break
        default:
            drawTraingle()
            drawRectangle()
            break
        }
    }

}
