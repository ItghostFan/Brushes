//
//  OpenGLController.swift
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
}

class OpenGLController: UIViewController, GLKViewDelegate {
    
    static private let triangleVertexSize = 3
    static private let rectangleVertexSize = triangleVertexSize * 2
    static private let rectangleVertexColumn = 5
    
    private var glkView = GLKView()
    private var glkBaseEffect = GLKBaseEffect()
    
    private var drawShape = DrawShape.Rectangle
    
    private var triangleVertexBuffer = UnsafeMutablePointer<GLuint>.allocate(capacity: 1)
    private var triangleVertices = UnsafeMutablePointer<GLKVector3>.allocate(capacity: triangleVertexSize)
    
    private var rectangleVertexBuffer = UnsafeMutablePointer<GLuint>.allocate(capacity: 1)
//    private var rectangleVertices = UnsafeMutablePointer<GLfloat>.allocate(capacity: rectangleVertexSize * rectangleVertexColumn)
    private var rectangleVertices =
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
        
        glkBaseEffect.useConstantColor = GLboolean(GL_TRUE)
        glkBaseEffect.constantColor = GLKVector4(v: (1.0, 1.0, 1.0, 1.0))
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        switch drawShape {
        case .Triangle:
            makeTriangle()
            break
        case .Rectangle:
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
        
        glGenBuffers(GLsizei(1), triangleVertexBuffer)
        print("Triangle Buffer \(triangleVertexBuffer[0])")
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), triangleVertexBuffer[0])
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLKVector3>.size * OpenGLController.triangleVertexSize,         triangleVertices, GLenum(GL_STATIC_DRAW))
    }
    
    func makeRectangle() {
        
        glGenBuffers(GLsizei(1), rectangleVertexBuffer)
        print("Rectangle Buffer \(rectangleVertexBuffer[0])")
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), rectangleVertexBuffer[0])
        let vertexSize = MemoryLayout<GLfloat>.size * OpenGLController.rectangleVertexColumn * OpenGLController.rectangleVertexSize
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexSize, rectangleVertices, GLenum(GL_STATIC_DRAW))
        
        let image = UIImage(named: "scrawl")?.cgImage
        do {
            let textureInfo = try? GLKTextureLoader.texture(with: image!, options: [GLKTextureLoaderOriginBottomLeft:true,GLKTextureLoaderGrayscaleAsAlpha:true,GLKTextureLoaderApplyPremultiplication:true])
            glkBaseEffect.texture2d0.name = textureInfo!.name
            glkBaseEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo!.target)!
        } catch {
            print("\(error)")
        }
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * OpenGLController.rectangleVertexColumn), UnsafeRawPointer(bitPattern: 0))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), GLint(2), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * OpenGLController.rectangleVertexColumn), UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 3));
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
        if rectangleVertexBuffer[0] != 0 {
            glDeleteBuffers(GLsizei(1), rectangleVertexBuffer)
        }
        rectangleVertexBuffer.deallocate()
    }
    
    func drawTraingle() {
        glVertexAttribPointer(
            GLuint(GLKVertexAttrib.position.rawValue),
            GLint(3),
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<GLKVector3>.size),
            UnsafeRawPointer(nil)
        )
        let vertexSize = GLsizei(OpenGLController.triangleVertexSize)
        glDrawArrays(GLenum(GL_TRIANGLES), GLint(0), vertexSize)
    }
    
    func drawRectangle() {
        glVertexAttribPointer(
            GLuint(GLKVertexAttrib.position.rawValue),
            GLint(3),
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(MemoryLayout<GLfloat>.size * OpenGLController.rectangleVertexColumn),
            nil
        )
        let vertexSize = GLsizei(OpenGLController.rectangleVertexSize)
        glDrawArrays(GLenum(GL_TRIANGLES), GLint(0), vertexSize)
    }
    
    // MARK: GLKViewDelegate
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glkBaseEffect.prepareToDraw()
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        switch drawShape {
        case .Triangle:
            drawTraingle()
            break
        case .Rectangle:
            drawRectangle()
            break
        }
    }
}
